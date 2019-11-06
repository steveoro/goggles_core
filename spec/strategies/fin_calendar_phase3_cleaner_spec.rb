# frozen_string_literal: true

require 'rails_helper'

describe FinCalendarPhase3Cleaner, type: :strategy do
  let( :fin_calendar_row )  { create(:fin_calendar) }
  let( :current_user )      { create(:user) }

  context 'with valid parameters,' do
    subject { FinCalendarPhase3Cleaner.new( current_user ) }

    it_behaves_like( '(the existance of a method)', [
                      :destroyed_rows_codes, :edited_rows_codes, :error_rows_codes,
                      :destroyed_rows_count, :edited_rows_count, :errors_count,
                      :has_changes?,
                      :collect_deletable_meetings,
                      :process!, :report,
                      :remove_empty_sessions!
                    ] )

    let(:record) { fin_calendar_row }
    it_behaves_like( 'SqlConverter [param: let(:record)]' )
    it_behaves_like( 'SqlConvertable [subject: includee]' )

    describe '#destroyed_rows_codes' do
      it 'is empty (before any processing)' do
        expect( subject.destroyed_rows_codes ).to be_empty
      end
    end

    describe '#destroyed_rows_count' do
      it 'is zero by default (before any processing)' do
        expect( subject.destroyed_rows_count ).to eq( 0 )
      end
    end

    describe '#error_rows_codes' do
      it 'is empty (before any processing)' do
        expect( subject.error_rows_codes ).to be_empty
      end
    end

    describe '#errors_count' do
      it 'is zero by default (before any processing)' do
        expect( subject.errors_count ).to eq( 0 )
      end
    end

    describe '#has_changes?' do
      it 'is false by default (before any processing)' do
        expect( subject.has_changes? ).to be false
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#collect_deletable_meetings' do
      context 'for a season w/o deletable meetings,' do
        let(:season_w_o_deletable_meetings) { Season.where(season_type_id: 2).all.sample }

        it 'returns an empty list' do
          expect(
            subject.collect_deletable_meetings( season_w_o_deletable_meetings.id )
          ).to be_empty
        end
      end

      context 'for a season w/ some deletable meetings,' do
        let(:season_w_deletable_meetings) { Season.find( 132 ) }

        it 'returns a non-empty list of meetings' do
          expect(
            subject.collect_deletable_meetings( season_w_deletable_meetings.id ).count
          ).to be > 0
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#process!' do
      it 'does not alter any row w/ a nil parameter' do
        expect do
          subject.process!( nil )
        end.not_to change(subject, :destroyed_rows_count)
      end
      it 'does not alter the SQL log w/ a nil parameter' do
        expect do
          subject.process!( nil )
        end.not_to change(subject, :sql_diff_text_log)
      end

      it 'does not alter any row w/ an empty parameter' do
        expect do
          subject.process!( [] )
        end.not_to change(subject, :destroyed_rows_count)
      end
      it 'does not alter the SQL log w/ an empty parameter' do
        expect do
          subject.process!( [] )
        end.not_to change(subject, :sql_diff_text_log)
      end

      context 'for a valid list of meetings (using default DESTROY),' do
        let( :deletable_meeting_list ) do
          list = FactoryBot.create_list( :meeting_with_sessions, 3 )
          # DEBUG
          #          puts "\r\n#{ list.first.inspect }"
          #          puts "=> valid: #{ list.first.valid? }"
          list
        end

        it 'increases the count of the destroyed rows' do
          expect do
            subject.process!( deletable_meeting_list )
          end.to change(subject, :destroyed_rows_count)
        end
        it 'adds the destroyed rows code to the list' do
          subject.process!( deletable_meeting_list )
          destroyed_codes = deletable_meeting_list.map { |row| "#{ row.code }/#{ row.id }" }
          expect( subject.destroyed_rows_codes ).to include( *destroyed_codes )
        end
        it 'adds the DELETE operation to the #sql_diff_text_log' do
          subject.process!( deletable_meeting_list )
          expect( subject.sql_diff_text_log ).to include('DELETE')
        end
        it 'changes #has_changes? to true' do
          expect do
            subject.process!( deletable_meeting_list )
          end.to change(subject, :has_changes?).to true
        end
      end

      context "for a valid list of meetings (using 'disable')," do
        let( :deletable_meeting_list ) do
          list = FactoryBot.create_list( :meeting_with_sessions, 3 )
          # DEBUG
          #          puts "\r\n#{ list.first.inspect }"
          #          puts "=> valid: #{ list.first.valid? }"
          list
        end

        it 'does NOT increases the count of the destroyed rows' do
          expect do
            subject.process!( deletable_meeting_list, true )
          end.not_to change(subject, :destroyed_rows_count)
        end
        it 'adds the edited rows code to the list' do
          subject.process!( deletable_meeting_list, true )
          edited_codes = deletable_meeting_list.map { |row| "#{row.code}/#{row.id}" }
          expect( subject.edited_rows_codes ).to include( *edited_codes )
        end
        it 'adds the UPDATE operation to the #sql_diff_text_log' do
          subject.process!( deletable_meeting_list, true )
          expect( subject.sql_diff_text_log ).to include('UPDATE')
        end
        it 'does NOT add the DELETE operation to the #sql_diff_text_log' do
          subject.process!( deletable_meeting_list, true )
          expect( subject.sql_diff_text_log ).not_to include('DELETE')
        end
        it 'changes #has_changes? to true' do
          expect do
            subject.process!( deletable_meeting_list )
          end.to change(subject, :has_changes?).to true
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#remove_empty_sessions!' do
      context 'for a season w/o deletable meeting sessions,' do
        subject { FinCalendarPhase3Cleaner.new( current_user ) }
        let(:season_w_o_deletable_sessions) { Season.where(season_type_id: 2).all.sample }

        # FIXME: Random failures: IMPROVE the FIXTURE CREATION
        xit 'it does not change the DB' do
          expect do
            subject.remove_empty_sessions!( season_w_o_deletable_sessions.id )
          end.not_to change(subject, :has_changes?)
        end
      end

      context 'for a season w/ some deletable meeting sessions,' do
        subject { FinCalendarPhase3Cleaner.new( current_user ) }

        let(:season_w_deletable_sessions) { Season.where(season_type_id: 1).includes(:meetings).joins(:meetings).all.sample }
        let(:random_meeting)              { season_w_deletable_sessions.meetings.sample }
        # Let's force-add an empty, deletable session to the chosen season:
        let(:empty_session) do
          expect( random_meeting ).to be_a( Meeting )
          expect( random_meeting.season_id ).to eq( season_w_deletable_sessions.id )
          session = FactoryBot.create( :meeting_session, meeting_id: random_meeting.id )
          expect( session ).to be_a( MeetingSession )
          # DEBUG
          #          puts "\r\n- session: #{ session.inspect }"
          #          puts "- session events: #{ session.meeting_events.count }"
          expect( session.meeting_events.count ).to eq(0)
          session
        end

        # FIXME: Random failures: IMPROVE the FIXTURE CREATION
        xit 'increases the count of the destroyed rows' do
          expect do
            subject.remove_empty_sessions!( season_w_deletable_sessions.id )
            # DEBUG
            #            puts subject.sql_diff_text_log
          end.to change(subject, :destroyed_rows_count)
        end

        # FIXME: Random failures: IMPROVE the FIXTURE CREATION
        xit 'adds the destroyed rows code to the list' do
          subject.remove_empty_sessions!( season_w_deletable_sessions.id )
          destroyed_code = "#{ empty_session.meeting_id }/#{ empty_session.id }"
          expect( subject.destroyed_rows_codes ).to include( destroyed_code )
        end

        # FIXME: Random failures: IMPROVE the FIXTURE CREATION
        xit 'adds the DELETE operation to the #sql_diff_text_log' do
          subject.remove_empty_sessions!( season_w_deletable_sessions.id )
          expect( subject.sql_diff_text_log ).to include('DELETE')
        end

        # FIXME: Random failures: IMPROVE the FIXTURE CREATION
        xit 'changes #has_changes? to true' do
          expect do
            subject.remove_empty_sessions!( season_w_deletable_sessions.id )
          end.to change(subject, :has_changes?).to true
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#report' do
      context 'before any processing,' do
        it 'reports nothing' do
          output = []
          expect { subject.report( output, :<< ) }
            .not_to change(output, :count)
        end
      end

      context 'after a #process! call,' do
        let( :deletable_meeting_list ) { FactoryBot.create_list( :meeting_with_sessions, 3 ) }

        it 'changes the output' do
          output = []
          subject.process!( deletable_meeting_list )
          expect { subject.report( output, :<< ) }
            .to change(output, :count)
        end
        it 'reports the destroyed meeting codes' do
          output = []
          subject.process!( deletable_meeting_list )
          # Make the end report:
          subject.report( output, :<< )
          destroyed_codes = deletable_meeting_list.map { |row| "- #{ row.code }/#{ row.id }" }
          expect( output ).to include( *destroyed_codes )
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
      expect { FinCalendarPhase3Cleaner.new }.to raise_error( ArgumentError )
      expect { FinCalendarPhase3Cleaner.new(nil) }.to raise_error( ArgumentError )
      expect { FinCalendarPhase3Cleaner.new(1) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
