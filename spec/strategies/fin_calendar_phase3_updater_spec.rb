# frozen_string_literal: true

require 'rails_helper'

describe FinCalendarPhase3Updater, type: :strategy do
  let( :fin_calendar_row )  { create(:fin_calendar) }
  let( :current_user )      { create(:user) }

  context 'with valid parameters,' do
    subject { FinCalendarPhase3Updater.new( current_user ) }

    it_behaves_like( '(the existance of a method)', [
                      :edited_rows_codes, :error_rows_codes,
                      :edited_rows_count, :errors_count, :action_log,
                      :process_row!, :report,
                      :has_changes?
                    ] )

    let(:record) { fin_calendar_row }
    it_behaves_like( 'SqlConverter [param: let(:record)]' )
    it_behaves_like( 'SqlConvertable [subject: includee]' )

    describe '#edited_rows_codes' do
      it 'is empty (before any processing)' do
        expect( subject.edited_rows_codes ).to be_empty
      end
    end

    describe '#edited_rows_count' do
      it 'is zero by default (before any processing)' do
        expect( subject.edited_rows_count ).to eq( 0 )
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

    describe '#action_log' do
      it 'is empty (before any processing)' do
        expect( subject.action_log ).to be_empty
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#process_row!' do
      it 'does not alter any row for a nil/empty parameter' do
        expect { subject.process_row!( nil, [] ) }
          .not_to change(subject, :edited_rows_count)
        expect { subject.process_row!( nil, [] ) }
          .not_to change(subject, :errors_count)
      end
      it 'does not alter the SQL log for a nil/empty parameter' do
        expect { subject.process_row!( nil, [] ) }
          .not_to change(subject, :sql_diff_text_log)
      end

      shared_examples_for 'process_row!() w/ an incomplete fin_calendar row' do
        it 'returns nil' do
          expect( subject.process_row!(fin_calendar_incomplete, []) ).to be nil
        end
        it 'does NOT change the count of the edited rows' do
          expect { subject.process_row!(fin_calendar_incomplete, []) }
            .not_to change(subject, :edited_rows_count)
        end
        it 'adds the code of the edited row to the #error_rows_codes list' do
          subject.process_row!( fin_calendar_incomplete, [] )
          expect( subject.error_rows_codes ).to include( "#{ fin_calendar_incomplete.goggles_meeting_code }/#{ fin_calendar_incomplete.id }" )
        end
      end

      context 'for a non-valid calendar row (w/ no program_import_text),' do
        let(:fin_calendar_incomplete) { build(:fin_calendar, program_import_text: '') }
        it_behaves_like 'process_row!() w/ an incomplete fin_calendar row'
      end
      context 'for a non-valid calendar row (w/ no goggles_meeting_code),' do
        let(:fin_calendar_incomplete) { build(:fin_calendar, goggles_meeting_code: '') }
        it_behaves_like 'process_row!() w/ an incomplete fin_calendar row'
      end
      context 'for a non-valid calendar row (w/ no calendar_name),' do
        let(:fin_calendar_incomplete) { build(:fin_calendar, calendar_name: '') }
        it_behaves_like 'process_row!() w/ an incomplete fin_calendar row'
      end
      context 'for a non-valid calendar row (w/ no calendar_place),' do
        let(:fin_calendar_incomplete) { build(:fin_calendar, calendar_place: '-') }
        it_behaves_like 'process_row!() w/ an incomplete fin_calendar row'
      end

      shared_examples_for 'process_row!() w/ a valid, updatable row' do
        it 'increases the count of the edited rows by 1' do
          parser.parse!
          expect do
            # geocoding, skip_acquired
            subject.process_row!( fin_calendar_row, parser.session_daos, false, false )
          end.to change(subject, :edited_rows_count).by(1)
        end
        it 'adds the code of the edited row to the #edited_rows_codes list' do
          # geocoding, skip_acquired
          subject.process_row!( fin_calendar_row, parser.session_daos, false, false )
          expect( subject.edited_rows_codes ).to include( "#{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }" )
        end
        it 'adds an UPDATE operation to the #sql_diff_text_log' do
          # geocoding, skip_acquired
          subject.process_row!( fin_calendar_row, parser.session_daos, false, false )
          expect( subject.sql_diff_text_log ).to include('UPDATE')
        end
      end

      context 'for a valid (random) calendar row (skip acquired OFF),' do
        let(:fin_calendar_row) do
          result = nil
          # Search for a full calendar row w/ a valid program text to be parsed:
          while result.nil?
            result = FinCalendar.where( season_id: 162 ).sample
            result = nil unless FinCalendarTextParser.contains_a_date?( result.program_import_text ) ||
                                FinCalendarTextParser.contains_a_time?( result.program_import_text )
          end
          # Let's make sure that the fixture program text actually contains at least a meeting session:
          expect(
            FinCalendarTextParser.contains_a_date?( result.program_import_text ) ||
            FinCalendarTextParser.contains_a_time?( result.program_import_text )
          ).to be true
          # Edit the fixture row so that it will be editied:
          result.meeting_id = nil
          result
        end
        let(:parser) { FinCalendarTextParser.new( fin_calendar_row ) }

        it_behaves_like 'process_row!() w/ a valid, updatable row'

        # ( describe "#report" use-case moved here since the fixture is already correctly defined above )
        context 'after calling #process_row!,' do
          describe '#report' do
            it 'reports the changed meeting code' do
              output = []
              # geocoding, skip_acquired
              subject.process_row!( fin_calendar_row, parser.session_daos, false, false )
              # Make the end report:
              subject.report( output, :<< )
              expect( output ).to include("- #{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }")
            end
          end
        end
      end

      context 'for a row linked to an existing acquired meeting w/ skip acquired ON,' do
        let(:fin_calendar_row) do
          result = nil
          # Search for a full calendar row w/ a valid program text to be parsed:
          while result.nil?
            result = FinCalendar.where( season_id: 162 ).sample
            meeting = Meeting.where( code: result.goggles_meeting_code, season_id: 162 ).first
            result = nil unless meeting&.are_results_acquired?
          end
          expect( meeting.are_results_acquired? ).to be true
          # Edit the fixture row so that it will be editied:
          result.meeting_id = nil
          result
        end

        let(:parser) { FinCalendarTextParser.new( fin_calendar_row ) }

        it 'increases the count of the edited rows by 1' do
          parser.parse!
          expect do
            # geocoding, skip_acquired
            subject.process_row!( fin_calendar_row, parser.session_daos, false, true )
          end.to change(subject, :edited_rows_count).by(1)
        end
        it 'adds the code of the edited row to the #edited_rows_codes list' do
          # geocoding, skip_acquired
          subject.process_row!( fin_calendar_row, parser.session_daos, false, true )
          expect( subject.edited_rows_codes ).to include( "#{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }" )
        end
        it 'adds an UPDATE operation to the #sql_diff_text_log' do
          # geocoding, skip_acquired
          subject.process_row!( fin_calendar_row, parser.session_daos, false, true )
          expect( subject.sql_diff_text_log ).to include('UPDATE')
        end

        # ( describe "#report" use-case moved here since the fixture is already correctly defined above )
        context 'after calling #process_row!,' do
          describe '#report' do
            it 'does not include the session processing' do
              output = []
              # geocoding, skip_acquired
              subject.process_row!( fin_calendar_row, parser.session_daos, false, true )
              # Make the end report:
              subject.report( output, :<< )
              expect( output ).not_to include('SESSION Begin')
              expect( output ).not_to include('MeetingEvent')
            end
          end
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
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with invalid parameters,' do
    it 'raises an ArgumentError' do
      expect { FinCalendarPhase3Updater.new }.to raise_error( ArgumentError )
      expect { FinCalendarPhase3Updater.new(nil) }.to raise_error( ArgumentError )
      expect { FinCalendarPhase3Updater.new(1) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
