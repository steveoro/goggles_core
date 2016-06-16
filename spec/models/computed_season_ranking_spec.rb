require 'spec_helper'


describe ComputedSeasonRanking, :type => :model do
  context "[a well formed instance]" do

    subject { create(:computed_season_ranking) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :team,
      :season
    ])
    # Filtering scopes:
    it_behaves_like( "(the existance of a class method)", [
      :for_team,
      :for_season,
      :sort_by_rank
    ])

    context "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty strings)", [
        :get_full_name,
        :get_verbose_name
      ])
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
