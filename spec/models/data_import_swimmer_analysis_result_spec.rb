require 'rails_helper'


describe DataImportSwimmerAnalysisResult, :type => :model do

  # This is mainly used to test the factory and its relationships:
  context "[Standard Factory]" do
    subject { create(:data_import_swimmer_analysis_result) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "has a valid #data_import_session instance" do
      expect( subject.data_import_session ).to be_valid
    end

    it_behaves_like( "(belongs_to required models)",
      [
        :data_import_session,
        :swimmer,
        :gender_type,
        :category_type
      ]
    )

    it_behaves_like( "(the existance of a method)",
      [
        :analysis_log_text, :sql_text, :searched_swimmer_name,
        :chosen_swimmer_id,
        :desired_year_of_birth,
        :desired_gender_type_id,

        :category_type_id,
        :max_year_of_birth,

        :match_name, :match_score,
        :best_match_name, :best_match_score,

        :is_a_perfect_match,
        :can_insert_alias,
        :can_insert_swimmer,
        :rebuild_sql_text,
        :to_s
      ]
    )

    it "has an empty valid #sql_text at start" do
      expect( subject.sql_text ).to eq('')
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#rebuild_sql_text" do
      subject { create(:data_import_swimmer_analysis_result) }
      context "when it can insert a new Swimmer," do
        before(:each) do
          subject.chosen_swimmer_id = nil
          expect( subject.can_insert_swimmer ).to be true
          expect( subject.can_insert_alias ).to be false
          subject.rebuild_sql_text
        end

        it "adds an 'INSERT INTO data_import_swimmers' statement in the #sql_text member" do
          expect( subject.sql_text ).to include( 'INSERT INTO data_import_swimmers' )
        end
        it "DOESN'T add an 'INSERT INTO data_import_swimmer_aliases' statement" do
          expect( subject.sql_text ).not_to include( 'INSERT INTO data_import_swimmer_aliases' )
        end
      end

      context "when it can insert a new Swimmer-Alias," do
        subject { create(:data_import_swimmer_analysis_result) }
        before(:each) do
          subject.searched_swimmer_name = subject.searched_swimmer_name.split(/\s+/).reverse.join(' ')
          expect( subject.can_insert_swimmer ).to be false
          expect( subject.can_insert_alias ).to be true
          subject.rebuild_sql_text
        end

        it "DOESN'T add an 'INSERT INTO data_import_swimmers' statement" do
          expect( subject.sql_text ).not_to include( 'INSERT INTO data_import_swimmers' )
        end
        it "adds an 'INSERT INTO data_import_swimmer_aliases' statement in the #sql_text member" do
          expect( subject.sql_text ).to include( 'INSERT INTO data_import_swimmer_aliases' )
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
