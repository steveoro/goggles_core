# frozen_string_literal: true

require 'rails_helper'

describe FinCalendarPhase1Updater, type: :strategy do
  let( :fin_calendar_row )  { create(:fin_calendar) }
  let( :current_user )      { create(:user) }

  context 'with valid parameters,' do
    subject { FinCalendarPhase1Updater.new( current_user ) }

    it_behaves_like( '(the existance of a method)', [
                      :edited_rows_codes, :created_rows_codes, :error_rows_codes,
                      :edited_rows_count, :created_rows_count, :errors_count,
                      :processed_rows,
                      :process_row!, :report
                    ] )

    it_behaves_like( '(the existance of a class method)', [
                      :is_different?
                    ] )

    let(:record) { fin_calendar_row }
    it_behaves_like( 'SqlConverter [param: let(:record)]' )
    it_behaves_like( 'SqlConvertable [subject: includee]' )

    describe '#processed_rows' do
      it 'is zero by default (before any processing)' do
        expect( subject.processed_rows ).to eq( 0 )
      end
    end

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

    describe '#created_rows_codes' do
      it 'is empty (before any processing)' do
        expect( subject.created_rows_codes ).to be_empty
      end
    end

    describe '#created_rows_count' do
      it 'is zero by default (before any processing)' do
        expect( subject.created_rows_count ).to eq( 0 )
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
    #-- -----------------------------------------------------------------------
    #++

    describe '#process_row!,' do
      it 'does not alter any row for a nil parameter' do
        expect { subject.process_row!( nil ) }
          .not_to change(subject, :processed_rows)
      end
      it 'does not alter the SQL log for a nil parameter' do
        expect { subject.process_row!( nil ) }
          .not_to change(subject, :sql_diff_text_log)
      end

      context 'for a new (random) calendar row,' do
        let(:random_goggles_code) { FFaker::Lorem.word.downcase }
        let(:new_rand_fixture)    { build(:fin_calendar, goggles_meeting_code: random_goggles_code) }

        it 'increases the count of the processed rows by 1' do
          expect do
            subject.process_row!( new_rand_fixture )
          end.to change(subject, :processed_rows).by(1)
        end
        it 'increases the count of the edited rows by 1' do
          expect { subject.process_row!( new_rand_fixture ) }
            .to change(subject, :created_rows_count)
            .by(1)
        end
        it 'does not increase the error count' do
          expect { subject.process_row!( new_rand_fixture ) }
            .not_to change(subject, :errors_count)
        end
        it 'adds the code of the created row to the #created_rows_codes list' do
          subject.process_row!( new_rand_fixture )
          expect( subject.created_rows_codes ).to include( "#{ new_rand_fixture.goggles_meeting_code }/#{ new_rand_fixture.id }" )
        end
        it 'adds an INSERT or an UPDATE operation to the #sql_diff_text_log' do
          subject.process_row!( new_rand_fixture )
          expect( subject.sql_diff_text_log ).to match(/INSERT|UPDATE/)
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    let(:fin_calendar_row_1) { build( :fin_calendar ) }
    let(:fin_calendar_row_2) { build( :fin_calendar ) }

    describe 'self.is_different?' do
      context 'when matching 2 rows different in calendar columns,' do
        it 'is true' do
          expect(
            FinCalendarPhase1Updater.is_different?( fin_calendar_row_1, fin_calendar_row_2 )
          ).to be true
        end
      end

      context 'when matching 2 rows NOT different in calendar columns,' do
        it 'is false' do
          expect(
            FinCalendarPhase1Updater.is_different?( fin_calendar_row_1, fin_calendar_row_1 )
          ).to be false
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

      context 'after a #process_row! call,' do
        let(:random_goggles_code) { FFaker::Lorem.word.downcase }
        let(:new_rand_fixture)    { build(:fin_calendar, goggles_meeting_code: random_goggles_code) }

        it 'reports the changed meeting code' do
          output = []
          subject.process_row!( new_rand_fixture )
          # Make the end report:
          subject.report( output, :<< )
          expect( output ).to include("- #{ new_rand_fixture.goggles_meeting_code }/#{ new_rand_fixture.id }")
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
      expect { FinCalendarPhase1Updater.new }.to raise_error( ArgumentError )
      expect { FinCalendarPhase1Updater.new(nil) }.to raise_error( ArgumentError )
      expect { FinCalendarPhase1Updater.new(1) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
