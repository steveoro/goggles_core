require 'rails_helper'


describe ChampionshipRankingCalculator, type: :strategy do
  let( :fix_season )  { Season.find(131) }     # Data forced from seeds

  subject { ChampionshipRankingCalculator.new( fix_season ) }

  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method)",
      [
        :get_involved_teams,
        :get_involved_meetings,
        :get_columns,
        :get_season_ranking,
        :save_computed_season_rank
      ]
    )
  end

  context "with requested parameters" do
    describe "#get_involved_teams," do
      it "returns a relation" do
        expect( subject.get_involved_teams ).to be_a_kind_of( ActiveRecord::Relation )
      end
      it "returns an empty array if the season hasn't affiliations" do
        empty_season = create(:season)
        empty_ranking = ChampionshipRankingCalculator.new( empty_season )
        expect( subject.get_involved_teams ).to be_a_kind_of( ActiveRecord::Relation )
        expect( empty_ranking.get_involved_teams.count ).to be_equal(0)
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_involved_meetings," do
      it "returns an enumerable" do
        expect( subject.get_involved_meetings ).to be_a_kind_of( ActiveRecord::Relation )
      end
      it "returns an empty array if the season hasn't affiliations" do
        empty_season = create(:season)
        empty_ranking = ChampionshipRankingCalculator.new( empty_season )
        expect( empty_ranking.get_involved_meetings ).to be_a_kind_of( ActiveRecord::Relation )
        expect( empty_ranking.get_involved_meetings.count ).to be_equal(0)
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_columns," do
      it "returns an enumerable" do
        expect( subject.get_columns ).to be_a_kind_of( Array )
      end
      it "return 3 columns in 2011-2012 CSI" do
        expect( ChampionshipRankingCalculator.new( Season.find(111) ).get_columns.count ).to be_equal(3)
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_season_ranking," do
      it "returns a ChampionshipDAO" do
        expect( subject.get_season_ranking ).to be_an_instance_of( ChampionshipDAO )
      end

      context "with 2013-2014 CSI season" do
        it "has found 2 columns for meeting scores" do
          expect( subject.get_season_ranking.columns.count ).to be_equal(2)        
        end
        it "has found 5 meetings involved" do
          expect( subject.get_season_ranking.meetings.count ).to be_equal(5)        
        end
        it "has found 14 teams involved" do
          expect( subject.get_season_ranking.team_scores.count ).to be_equal(14)        
        end
        it "has found CSI Nuoto Ober Ferrari (1) in 2nd position" do
          expect( subject.get_season_ranking.team_scores[1].team.id ).to be_equal(1)        
        end
        it "has found CSI Nuoto Ober Ferrari with 3136 points" do
          expect( subject.get_season_ranking.team_scores[1].total_points.to_i ).to be_equal(3136)        
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#save_computed_season_rank" do
      it "returns true on no-errors found for not yet computed ranking" do
        expect( subject.save_computed_season_rank ).to be true
        expect( subject.save_computed_season_rank( 2 ) ).to be true
      end
      it "returns true on no-errors found for ranking already computed" do
        subject.get_season_ranking
        expect( subject.save_computed_season_rank ).to be true
        expect( subject.save_computed_season_rank( 2 ) ).to be true
      end
      it "increases the table size when persisting non existing records" do
        # Assumes anly the first three ranked team has been alreday stored
        expect{ subject.save_computed_season_rank( 14 ) }.to change{ ComputedSeasonRanking.count }
      end
      it "doesn't increase the table size when persisting existing records" do
        subject.save_computed_season_rank  # make sure the record already persist
        expect{ subject.save_computed_season_rank }.not_to change{ ComputedSeasonRanking.count }
      end
      it "returns true on no-errors even if not enough ranked teams" do
        expect( subject.save_computed_season_rank( 5689 ) ).to be true
      end
    end
    #-- -------------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
