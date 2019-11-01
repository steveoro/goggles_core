require 'rails_helper'


describe FinCalendarPhase2Updater, type: :strategy do

  let( :fin_calendar_row )  { create(:fin_calendar) }
  let( :current_user )      { create(:user) }

  context "with valid parameters," do
    subject { FinCalendarPhase2Updater.new( current_user ) }

    it_behaves_like( "(the existance of a method)", [
      :edited_rows_codes, :error_rows_codes,
      :edited_rows_count, :errors_count,
      :process_row!, :report
    ] )

    it_behaves_like( "(the existance of a class method)", [
      :is_different?
    ] )

    let(:record) { fin_calendar_row }
    it_behaves_like( "SqlConverter [param: let(:record)]" )
    it_behaves_like( "SqlConvertable [subject: includee]" )


    describe "#edited_rows_codes" do
      it "is empty (before any processing)" do
        expect( subject.edited_rows_codes ).to be_empty
      end
    end

    describe "#edited_rows_count" do
      it "is zero by default (before any processing)" do
        expect( subject.edited_rows_count ).to eq( 0 )
      end
    end

    describe "#error_rows_codes" do
      it "is empty (before any processing)" do
        expect( subject.error_rows_codes ).to be_empty
      end
    end

    describe "#errors_count" do
      it "is zero by default (before any processing)" do
        expect( subject.errors_count ).to eq( 0 )
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#process_row!" do
      it "does not alter any row for a nil parameter" do
        expect{
          subject.process_row!( nil )
        }.not_to change{ subject.edited_rows_count + subject.errors_count }
      end
      it "does not alter the SQL log for a nil parameter" do
        expect{
          subject.process_row!( nil )
        }.not_to change{ subject.sql_diff_text_log }
      end

      context "for a new (random) calendar row," do
        it "increases the count of the edited rows by 1" do
          # Make some changes and process them:
          fin_calendar_row.program_import_text = FFaker::Lorem.word
          expect{
            subject.process_row!( fin_calendar_row )
          }.to change{ subject.edited_rows_count }.by(1)
        end
        it "adds the code of the edited row to the #edited_rows_codes list" do
          # Make some changes and process them:
          fin_calendar_row.program_import_text = FFaker::Lorem.word
          subject.process_row!( fin_calendar_row )
          expect( subject.edited_rows_codes ).to include( "#{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }" )
        end
        it "adds an UPDATE operation to the #sql_diff_text_log" do
          # Make some changes and process them:
          fin_calendar_row.program_import_text = FFaker::Lorem.word
          subject.process_row!( fin_calendar_row )
          expect( subject.sql_diff_text_log ).to include("UPDATE")
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    let(:fin_calendar_row_1) { build( :fin_calendar, program_import_text: FFaker::Lorem.word ) }
    let(:fin_calendar_row_2) { build( :fin_calendar, program_import_text: FFaker::Lorem.word ) }

    describe "self.is_different?" do
      context "when matching 2 rows different in text columns," do
        it "is true" do
          expect(
            FinCalendarPhase2Updater.is_different?( fin_calendar_row_1, fin_calendar_row_2 )
          ).to be true
        end
      end

      context "when matching 2 rows NOT different in text columns," do
        it "is false" do
          expect(
            FinCalendarPhase2Updater.is_different?( fin_calendar_row_1, fin_calendar_row_1 )
          ).to be false
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#report" do
      context "before any processing," do
        it "reports nothing" do
          output = []
          expect{ subject.report( output, :<< ) }.not_to change{ output }
        end
      end

      context "after a #process_row! call," do
        it "reports the changed meeting code" do
          output = []
          # Make some changes and process them:
          fin_calendar_row.program_import_text = FFaker::Lorem.word
          subject.process_row!( fin_calendar_row )
          # Make the end report:
          subject.report( output, :<< )
          expect( output ).to include("- #{ fin_calendar_row.goggles_meeting_code }/#{ fin_calendar_row.id }")
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
      expect{ FinCalendarPhase2Updater.new }.to raise_error( ArgumentError )
      expect{ FinCalendarPhase2Updater.new(nil) }.to raise_error( ArgumentError )
      expect{ FinCalendarPhase2Updater.new(1) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
