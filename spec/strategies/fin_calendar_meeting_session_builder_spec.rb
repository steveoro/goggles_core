require 'rails_helper'


describe FinCalendarMeetingSessionBuilder, type: :strategy do

  let( :meeting )                   { Meeting.where(are_results_acquired: true).sample }
  let( :existing_meeting_session )  { meeting.meeting_events.sample.meeting_session }
  let( :existing_events )           { existing_meeting_session.meeting_events }
  let( :dao_for_existing_ms ) do
    dao = FinCalendarParseResultDAO.new(
      existing_meeting_session.scheduled_date.day.to_s,
      I18n.t("date.month_names")[ existing_meeting_session.scheduled_date.month ],
      existing_meeting_session.session_order,
      "Session at: #{ existing_meeting_session.scheduled_date }, #{ FFaker::Lorem.paragraph }"
    )
    dao.header_date_iso_format = existing_meeting_session.scheduled_date.to_s
    dao.start_time_iso_format  = Format.a_time( existing_meeting_session.begin_time )
    dao.day_part_type_id       = existing_meeting_session.day_part_type_id
    # Construct the DAO as if we had correctly parsed the events:
    existing_events.each{ |me| dao.add_meeting_event( me ) }
# DEBUG
#    puts "\r\n- :dao_for_existing_ms => #{ dao }"
    dao
  end
  #-- -------------------------------------------------------------------------
  #++


  context "with valid parameters," do
    subject { FinCalendarMeetingSessionBuilder.new( User.find(1), dao_for_existing_ms, meeting ) }

    it_behaves_like( "(the existance of a method)", [
      :result_meeting_session, :report, :find_or_create!,
      :has_updated, :has_created, :has_errors, :has_changes?
    ] )
    #-- -----------------------------------------------------------------------
    #++


    describe "#report" do
      context "right from the start," do
        it "creates a log header" do
          output = []
          expect{ subject.report( output, :<< ) }.to change{ output }
        end
        it "includes the meeting id in the process log" do
          output = []
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to include( meeting.id.to_s )
        end
      end

      context "after a #find_or_create! call (with an existing MeetingSession)," do
        it "reports that the specified MeetingSession was found" do
          output = []
          subject.find_or_create!()
          # Make the end report:
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to include( "Meeting Session found!" )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#find_or_create!" do
      context "when called for an existing MeetingSession," do
        subject { FinCalendarMeetingSessionBuilder.new( User.find(1), dao_for_existing_ms, meeting ) }

        it "sets the #result_meeting member to the expected MeetingSession row (w/ NO changes to the DB)" do
          # Let's make sure that we really have a fixture like that in the DB:
          expect( existing_meeting_session ).to be_a( MeetingSession )
          existing_meeting_session.description = "FINALS"
          expect( existing_meeting_session.save ).to be true

          subject.find_or_create!()
          expect( subject.result_meeting_session ).to be_a( MeetingSession )
# DEBUG
#          subject.report
          expect( subject.result_meeting_session.id ).to eq( existing_meeting_session.id )
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be false
        end
      end


      context "when called for an existing MeetingSession w/ different begin time," do
        let( :surely_different_time )      { "03:00" } # This is to make sure it will be different from original
        let( :dao_for_existing_w_changes ) do
          dao = FinCalendarParseResultDAO.new(
            existing_meeting_session.scheduled_date.day.to_s,
            I18n.t("date.month_names")[ existing_meeting_session.scheduled_date.month ],
            existing_meeting_session.session_order,
            "Session at: #{ existing_meeting_session.scheduled_date }, #{ FFaker::Lorem.paragraph }"
          )
          dao.header_date_iso_format = existing_meeting_session.scheduled_date.to_s
          dao.start_time_iso_format  = surely_different_time
          dao.day_part_type_id       = existing_meeting_session.day_part_type_id
          # Construct the DAO as if we had correctly parsed the events:
          existing_events.each{ |me| dao.add_meeting_event( me ) }
# DEBUG
#          puts "\r\n- :dao_for_existing_w_changes => #{ dao }"
          dao
        end
        subject { FinCalendarMeetingSessionBuilder.new( User.find(1), dao_for_existing_w_changes, meeting ) }

        it "sets the #result_meeting member to the expected MeetingSession row and updates its begin_time (CHANGING the DB)" do
          # Let's make sure that we really have a fixture like that in the DB:
          expect( existing_meeting_session ).to be_a( MeetingSession )
          existing_meeting_session.description = "FINALS"
          expect( existing_meeting_session.save ).to be true
          # Let's make sure that the meeting row was different before the call:
          expect( Format.a_time( existing_meeting_session.begin_time ) ).not_to eq( surely_different_time )

          subject.find_or_create!()
          expect( subject.result_meeting_session ).to be_a( MeetingSession )
          expect( Format.a_time( subject.result_meeting_session.begin_time ) ).to eq( surely_different_time )
# DEBUG
#          subject.report
          expect( subject.result_meeting_session.id ).to eq( existing_meeting_session.id )
          expect( subject.has_updated ).to be true
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be true
        end
      end


      context "when called for a NOT-yet existing MeetingSession," do
        let( :another_time )              { "03:00" }
        let( :existing_event_type_ids )   { meeting.event_types.map{ |et| et.id } }
        # To be sure the event won't be an existing one, let's exclude all the existing:
        let( :new_event_type )            { EventType.where("id not in (?)", existing_event_type_ids).sample }
        # Build a not-yet existing (but allegedly parsed) new event:
        let( :new_meeting_event ) do
          MeetingEvent.new(
            meeting_session_id: nil,
            event_order:        1,
            begin_time:         another_time,
            event_type_id:      new_event_type.id,
            heat_type_id:       HeatType::FINALS_ID,
            is_out_of_race:     false,
            is_autofilled:      true,
            user_id:            1,
            has_separate_gender_start_list:   true,
            has_separate_category_start_list: false
          )
        end
        let( :session_date )              { meeting.header_date + 1.day }
        let( :session_order )             { meeting.meeting_sessions.count + 1 }
        # Build-up the parsing result DAO for this spec:
        let( :dao_for_new ) do
          dao = FinCalendarParseResultDAO.new(
            session_date.day.to_s,
            I18n.t("date.month_names")[ session_date.month ],
            session_order,
            "Session at: #{ session_date }, #{ FFaker::Lorem.paragraph }"
          )
          dao.header_date_iso_format = session_date.to_s
          dao.start_time_iso_format  = another_time
          dao.day_part_type_id       = DayPartType::NIGHT_ID
          dao.add_meeting_event( new_meeting_event )
          dao
        end
        subject { FinCalendarMeetingSessionBuilder.new( User.find(1), dao_for_new, meeting ) }
        let(:result) do
          # Let's make sure that the fixture's MeetingSession doesn't exist in the DB:
          expect( MeetingSession.where(meeting_id: meeting.id, scheduled_date: session_date, session_order: session_order).count ).to eq(0)
          subject.find_or_create!()
        end


        it "returns a MeetingSession instance" do
          expect( result ).to be_a( MeetingSession )
        end
        it "creates a new MeetingSession with the expected session order, date, time and meeting id (CHANGING the DB)" do
          expect( result.meeting_id ).to eq( meeting.id )
          expect( result.scheduled_date ).to eq( session_date )
          expect( result.session_order ).to eq( session_order )
          expect( Format.a_time( result.begin_time ) ).to eq( another_time )
          expect( result.id ).to be > 0
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


  context "with invalid parameters," do
    it "raises an ArgumentError" do
      expect{ FinCalendarMeetingSessionBuilder.new }.to raise_error( ArgumentError )
      expect{ FinCalendarMeetingSessionBuilder.new(nil, nil) }.to raise_error( ArgumentError )
      expect{ FinCalendarMeetingSessionBuilder.new(nil, nil, nil) }.to raise_error( ArgumentError )
      expect{ FinCalendarMeetingSessionBuilder.new(1, nil, nil) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
