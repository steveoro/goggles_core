require 'rails_helper'


describe DataImportTeamAnalysisResult, :type => :model do

  # This is mainly used to test the factory and its relationships:
  context "[Standard Factory]" do
    subject { create(:data_import_team_analysis_result) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "has a valid #data_import_session instance" do
      expect( subject.data_import_session ).to be_valid
    end

    it_behaves_like( "(belongs_to required models)",
      [
        :data_import_session,
        :season,
        :team
      ]
    )

    it_behaves_like( "(the existance of a method)",
      [
        :analysis_log_text, :sql_text, :searched_team_name,
        :desired_season_id, :chosen_team_id,
        :team_match_name, :team_match_score,
        :best_match_name, :best_match_score,

        :is_a_perfect_match,
        :can_insert_alias,
        :can_insert_team,
        :can_insert_affiliation,
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
      subject { create(:data_import_team_analysis_result) }
      context "when it can insert a new Team," do
        before(:each) do
          subject.chosen_team_id = nil
          expect( subject.can_insert_team ).to be true
          expect( subject.can_insert_alias ).to be false
          expect( subject.can_insert_affiliation ).to be false
          subject.rebuild_sql_text
        end

        it "adds an 'INSERT INTO data_import_swimmers' statement in the #sql_text member" do
          expect( subject.sql_text ).to include( 'INSERT INTO data_import_teams' )
        end
        it "DOESN'T add an 'INSERT INTO data_import_team_aliases' statement" do
          expect( subject.sql_text ).not_to include( 'INSERT INTO data_import_team_aliases' )
        end
        it "DOESN'T add an 'INSERT INTO team_affiliations' statement" do
          expect( subject.sql_text ).not_to include( 'INSERT INTO team_affiliations' )
        end
      end

      context "when it can insert a new Team-Alias," do
        subject { create(:data_import_team_analysis_result) }
        before(:each) do
          expect( subject.can_insert_team ).to be false
          expect( subject.can_insert_alias ).to be true
          expect( subject.can_insert_affiliation ).to be false
          subject.rebuild_sql_text
        end

        it "DOESN'T add an 'INSERT INTO data_import_swimmers' statement" do
          expect( subject.sql_text ).not_to include( 'INSERT INTO data_import_teams' )
        end
        it "adds an 'INSERT INTO data_import_team_aliases' statement in the #sql_text member" do
          expect( subject.sql_text ).to include( 'INSERT INTO data_import_team_aliases' )
        end
        it "DOESN'T add an 'INSERT INTO team_affiliations' statement" do
          expect( subject.sql_text ).not_to include( 'INSERT INTO team_affiliations' )
        end
      end

      context "when it can insert a new Team Affiliation," do
        subject { create(:data_import_team_analysis_result) }
        before(:each) do
          subject.best_match_name = nil
          expect( subject.can_insert_team ).to be false
          expect( subject.can_insert_alias ).to be true
          expect( subject.can_insert_affiliation ).to be true
          subject.rebuild_sql_text
        end

        it "DOESN'T add an 'INSERT INTO data_import_swimmers' statement" do
          expect( subject.sql_text ).not_to include( 'INSERT INTO data_import_teams' )
        end
        it "adds an 'INSERT INTO data_import_team_aliases' statement in the #sql_text member" do
          expect( subject.sql_text ).to include( 'INSERT INTO data_import_team_aliases' )
        end
        it "DOESN'T add an 'INSERT INTO team_affiliations' statement in the #sql_text member" do
          expect( subject.sql_text ).not_to include( 'INSERT INTO team_affiliations' )
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
