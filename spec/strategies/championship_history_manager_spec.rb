require 'rails_helper'


describe ChampionshipHistoryManager, type: :strategy do
  let( :fix_season_type )  { SeasonType.find_by_code('MASCSI') }     # Data forced from seeds (MASCSI)

  subject { ChampionshipHistoryManager.new( fix_season_type ) }

  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method)",
      [
        :get_closed_seasons,
        :get_season_ranking_history,
        :get_involved_teams,
        :get_season_hall_of_fame
      ]
    )
  end

  context "with requested parameters" do
    describe "#get_closed_seasons," do
      it "returns a relation" do
        expect( subject.get_closed_seasons ).to be_a_kind_of( ActiveRecord::Relation )
      end
      it "returns a relation of Seasons" do
        expect( subject.get_closed_seasons ).to all(be_an_instance_of( Season ))
      end
      it "returns at least 10 seasons for CSIMAS" do
        expect( subject.get_closed_seasons.count ).to be > 10
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_season_ranking_history," do
      it "returns an array" do
        expect( subject.get_season_ranking_history ).to be_a_kind_of( Array )
      end
      it "returns an array of hash" do
        expect( subject.get_season_ranking_history ).to all(be_a_kind_of( Hash ))
      end
      it "returns an array of hash which responds to season, ranking and max_updated_at" do
        subject.get_season_ranking_history.each do |closed_season|
          expect( closed_season.keys ).to include(:season, :ranking, :max_updated_at)
        end
      end
      it "returns an array of hash which contains a season" do
        subject.get_season_ranking_history.each do |closed_season|
          expect( closed_season[:season] ).to be_an_instance_of( Season )
        end
      end
      it "returns an array of hash which contains a relation" do
        subject.get_season_ranking_history.each do |closed_season|
          expect( closed_season[:ranking] ).to be_a_kind_of( ActiveRecord::Relation )
        end
      end
      it "returns an array of hash which contains a relation of ComputedSeasonRanking" do
        subject.get_season_ranking_history.each do |closed_season|
          expect( closed_season[:ranking] ).to all(be_a_kind_of( ComputedSeasonRanking ))
        end
      end
      it "returns an array of hash which contains a relation of ComputedSeasonRanking" do
        subject.get_season_ranking_history.each do |closed_season|
          expect( closed_season[:ranking] ).to all(be_a_kind_of( ComputedSeasonRanking ))
        end
      end
      it "returns maximum 3 elements per rankng" do
        subject.get_season_ranking_history.each do |closed_season|
          expect( closed_season[:ranking].count ).to be <= 3
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_involved_teams," do
      it "returns a relation" do
        expect( subject.get_involved_teams ).to be_a_kind_of( ActiveRecord::Relation )
      end
      it "returns a relation of Seasons" do
        expect( subject.get_involved_teams ).to all(be_an_instance_of( Team ))
      end
      it "returns at least 3 teams for CSIMAS" do
        expect( subject.get_involved_teams.count ).to be >= 3
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_season_hall_of_fame," do
      it "returns an array" do
        expect( subject.get_season_hall_of_fame ).to be_a_kind_of( Array )
      end
      it "returns an array of hash" do
        expect( subject.get_season_hall_of_fame ).to all(be_a_kind_of( Hash ))
      end
      it "returns an array of hash which responds to season and ranking" do
        subject.get_season_hall_of_fame.each do |ranked_team|
          expect( ranked_team.keys ).to include(:team, :first_place, :second_place, :third_place)
        end
      end
      it "returns an array of hash which contains a team" do
        subject.get_season_hall_of_fame.each do |ranked_team|
          expect( ranked_team[:team] ).to be_an_instance_of( Team )
        end
      end
      it "returns an array of hash which contains numerical value on first_place" do
        [:first_place, :second_place, :third_place].each do |rank_key|
          subject.get_season_hall_of_fame.each do |ranked_team|
            expect( ranked_team[rank_key] ).to be >= 0
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++
end
