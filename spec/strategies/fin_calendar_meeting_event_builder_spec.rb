# frozen_string_literal: true

require 'rails_helper'

describe FinCalendarMeetingEventBuilder, type: :strategy do
  let( :existing_meeting_session ) { MeetingEvent.all.sample.meeting_session }
  let( :dao_for_existing_ms ) do
    # Let's make sure that the fixture is ok:
    expect( existing_meeting_session.meeting_events.count ).to be > 0
    # Prepare the DAO manually:
    dao = FinCalendarParseResultDAO.new(
      existing_meeting_session.scheduled_date.day.to_s,
      I18n.t('date.month_names')[existing_meeting_session.scheduled_date.month],
      existing_meeting_session.session_order,
      "Event at: #{ existing_meeting_session.scheduled_date }, #{ FFaker::Lorem.paragraph }"
    )
    dao.header_date_iso_format = existing_meeting_session.scheduled_date.to_s
    dao.start_time_iso_format  = Format.a_time( existing_meeting_session.begin_time )
    # Build-up the event list for the DAO from the selected session:
    existing_meeting_session.meeting_events.each do |meeting_event|
      dao.add_meeting_event( meeting_event )
    end
    # DEBUG
    #    puts "\r\n- :dao_for_existing_ms => #{ dao }"
    dao
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with valid parameters,' do
    subject { FinCalendarMeetingEventBuilder.new( User.find(1), dao_for_existing_ms, existing_meeting_session ) }

    it_behaves_like( '(the existance of a method)', [
                      :result_meeting_events, :last_event_order,
                      :report, :find_or_create!,
                      :has_updated, :has_created, :has_errors, :has_changes?
                    ] )
    #-- -----------------------------------------------------------------------
    #++

    describe '#report' do
      context 'right from the start,' do
        it 'creates a log header' do
          output = []
          expect { subject.report( output, :<< ) }
            .to change(output, :count)
        end
        it 'includes the existing meeting_session description in the process log' do
          output = []
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to include( existing_meeting_session.get_full_name )
        end
      end

      context 'after a #find_or_create! call (with an existing MeetingEvent),' do
        it 'reports that the specified MeetingEvent was found' do
          output = []
          subject.find_or_create!
          # Make the end report:
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to include( 'Meeting Event found!' )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#find_or_create!' do
      context 'when called for an existing list of meeting events,' do
        subject { FinCalendarMeetingEventBuilder.new( User.find(1), dao_for_existing_ms, existing_meeting_session ) }

        it 'returns the list of #result_meeting_events, with the same pre-existing events (w/ NO changes to the DB)' do
          expect( subject.result_meeting_events ).to eq( [] )
          subject.find_or_create!
          # DEBUG
          #          subject.report
          expect( subject.result_meeting_events ).to be_an( Array )
          expect( subject.result_meeting_events ).to eq( existing_meeting_session.meeting_events )
          # After the above test, this is pointless. ('Kept only as reference of previous version)
          #          expect( subject.result_meeting_events.map{ |row| row.event_order } ).to eq( existing_meeting_session.meeting_events.to_a.map{ |row| row.event_order } )
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be false
        end
      end

      # [Steve, 20170920] We cannot safely detect the begin time from the start time
      # of the session. (We need the entries, at least.) So we cannot update the start-time
      # of the event, even if it is different from the existing event found.
      context 'when called for an existing MeetingEvent w/ different begin time,' do
        let( :surely_different_time )      { '03:00' } # This is to make sure it will be different from original
        let( :dao_for_existing_w_changes ) do
          dao = FinCalendarParseResultDAO.new(
            existing_meeting_session.scheduled_date.day.to_s,
            I18n.t('date.month_names')[existing_meeting_session.scheduled_date.month],
            existing_meeting_session.session_order,
            "Event at: #{ existing_meeting_session.scheduled_date }, #{ FFaker::Lorem.paragraph }"
          )
          dao.header_date_iso_format = existing_meeting_session.scheduled_date.to_s
          dao.start_time_iso_format  = surely_different_time
          # Build-up the event list for the DAO from the selected session:
          existing_meeting_session.meeting_events.each do |meeting_event|
            dao.add_meeting_event( meeting_event )
          end
          # DEBUG
          #          puts "\r\n- :dao_for_existing_w_changes => #{ dao }"
          dao
        end

        subject { FinCalendarMeetingEventBuilder.new( User.find(1), dao_for_existing_w_changes, existing_meeting_session ) }

        it 'sets the #result_meeting member to the expected event rows, with the same pre-existing events (w/ NO changes to the DB)' do
          # Let's make sure that the meeting row was different before the call:
          expect( Format.a_time( existing_meeting_session.begin_time ) ).not_to eq( surely_different_time )
          subject.find_or_create!
          # DEBUG
          #          subject.report
          expect( subject.result_meeting_events ).to be_an( Array )
          expect( subject.result_meeting_events.map(&:id) ).to match_array( existing_meeting_session.meeting_events.to_a.map(&:id) )
          expect( subject.result_meeting_events.map(&:meeting_session_id).uniq.first ).to eq( existing_meeting_session.id )
          # [Steve] See note above:
          #          subject.result_meeting_events.each do |event|
          #            expect( Format.a_time( event.begin_time ) ).to eq( surely_different_time )
          #          end
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be false
        end
      end

      context 'when called for a NOT-yet existing MeetingEvent,' do
        let( :already_defined_types ) { existing_meeting_session.meeting_events.map(&:event_type_id) }
        let( :new_event_type )        { EventType.where('id NOT IN (?)', already_defined_types).sample }
        let( :new_event ) do
          MeetingEvent.new(
            event_type_id: new_event_type.id,
            heat_type_id: HeatType::FINALS_ID,
            begin_time: '18:00'
          )
        end
        let( :dao_for_new ) do
          dao = FinCalendarParseResultDAO.new(
            existing_meeting_session.scheduled_date.day.to_s,
            I18n.t('date.month_names')[existing_meeting_session.scheduled_date.month],
            existing_meeting_session.session_order,
            "Event at: #{ existing_meeting_session.scheduled_date }, #{ FFaker::Lorem.paragraph }"
          )
          dao.header_date_iso_format = existing_meeting_session.scheduled_date.to_s
          dao.start_time_iso_format  = Format.a_time( existing_meeting_session.begin_time )
          # Build-up the event list for the DAO from the selected session:
          existing_meeting_session.meeting_events.each do |meeting_event|
            dao.add_meeting_event( meeting_event )
          end
          # Add a new event to the existing session already set in the DAO:
          dao.add_meeting_event( new_event )
          # DEBUG
          #          puts "\r\n- :dao_for_new => #{ dao }"
          dao
        end

        subject { FinCalendarMeetingEventBuilder.new( User.find(1), dao_for_new, existing_meeting_session ) }

        it 'returns a MeetingEvent instance' do
          # Let's make sure that the fixture's MeetingEvent doesn't exist in the DB:
          expect( MeetingEvent.where(meeting_session_id: existing_meeting_session.id, event_type_id: new_event_type.id).count ).to eq(0)
          subject.find_or_create!

          expect( subject.result_meeting_events ).to be_an( Array )
          expect( subject.result_meeting_events.map(&:event_type_id) ).to include( new_event_type.id )
        end

        it 'creates an additional, new MeetingEvent with the expected values (CHANGING the DB)' do
          # Let's make sure that the fixture's MeetingEvent doesn't exist in the DB:
          expect( MeetingEvent.where(meeting_session_id: existing_meeting_session.id, event_type_id: new_event_type.id).count ).to eq(0)
          subject.find_or_create!
          # DEBUG
          #          subject.report
          expect( subject.result_meeting_events.last.id ).to be > 0
          expect( subject.result_meeting_events.last.event_type_id ).to eq( new_event_type.id )
          expect( subject.result_meeting_events.last.meeting_session_id ).to eq( existing_meeting_session.id )
          #          expect( Format.a_time(subject.result_meeting_events.last.begin_time) ).to eq( new_event.begin_time )
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be true
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be true
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with invalid parameters,' do
    it 'raises an ArgumentError' do
      expect { FinCalendarMeetingEventBuilder.new }.to raise_error( ArgumentError )
      expect { FinCalendarMeetingEventBuilder.new(nil, nil) }.to raise_error( ArgumentError )
      expect { FinCalendarMeetingEventBuilder.new(nil, nil, nil) }.to raise_error( ArgumentError )
      expect { FinCalendarMeetingEventBuilder.new(1, nil, nil) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
