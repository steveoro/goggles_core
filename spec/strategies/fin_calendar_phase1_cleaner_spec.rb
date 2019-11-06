# frozen_string_literal: true

require 'rails_helper'

describe FinCalendarPhase1Cleaner, type: :strategy do
  let( :fin_calendar_row )  { create(:fin_calendar) }
  let( :current_user )      { create(:user) }

  context 'with valid parameters,' do
    subject { FinCalendarPhase1Cleaner.new( current_user ) }

    it_behaves_like( '(the existance of a method)', [
                      :destroyed_rows_codes, :error_rows_codes,
                      :destroyed_rows_count, :errors_count,
                      :process!, :report
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
    #-- -----------------------------------------------------------------------
    #++

    let( :src_fin_calendar_list )   { create_list(:fin_calendar, 5) }
    let( :dest_fin_calendar_list )  { create_list(:fin_calendar, 3) }

    describe '#process_row!,' do
      it 'does not alter any row w/ nil parameters' do
        expect  do
          subject.process!( nil, nil )
        end.not_to change(subject, :destroyed_rows_count)
      end
      it 'does not alter the SQL log w/ nil parameters' do
        expect { subject.process!(nil, nil) }
          .not_to change(subject, :sql_diff_text_log)
      end

      context 'for a new (random) calendar row,' do
        it 'increases the count of the destroyed rows' do
          expect { subject.process!(src_fin_calendar_list, dest_fin_calendar_list) }
            .to change(subject, :destroyed_rows_count)
        end
        it 'adds the destroyed rows code to the list' do
          subject.process!( src_fin_calendar_list, dest_fin_calendar_list )
          destroyed_codes = dest_fin_calendar_list.map { |row| "#{row.goggles_meeting_code}/#{row.id}" }
          expect( subject.destroyed_rows_codes ).to include( *destroyed_codes )
        end
        it 'adds the DELETE operation to the #sql_diff_text_log' do
          subject.process!( src_fin_calendar_list, dest_fin_calendar_list )
          expect( subject.sql_diff_text_log ).to include('DELETE')
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#report' do
      context 'before any processing,' do
        it 'reports nothing' do
          output = []
          expect   { subject.report( output, :<< ) }
            .not_to change(output, :count)
        end
      end

      context 'after a #process! call,' do
        it 'changes the output' do
          output = []
          subject.process!(src_fin_calendar_list, dest_fin_calendar_list)
          expect { subject.report( output, :<< ) }
            .to change(output, :count)
        end
        it 'reports the destroyed meeting codes' do
          output = []
          subject.process!(src_fin_calendar_list, dest_fin_calendar_list)
          # Make the end report:
          subject.report( output, :<< )
          destroyed_codes = dest_fin_calendar_list.map { |row| "- #{row.goggles_meeting_code}/#{row.id}" }
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
      expect { FinCalendarPhase1Cleaner.new }.to raise_error( ArgumentError )
      expect { FinCalendarPhase1Cleaner.new(nil) }.to raise_error( ArgumentError )
      expect { FinCalendarPhase1Cleaner.new(1) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
