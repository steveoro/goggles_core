require 'spec_helper'


describe TeamAffiliation, :type => :model do
  describe "[a non-valid instance]" do
    it_behaves_like( "(missing required values)", [
      :name
    ])
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "[a well formed instance]" do
    subject { create( :team_affiliation ) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :team,
      :season,
      :season_type
    ])

    context "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty strings)", [
        :get_full_name,
        :get_verbose_name
      ])
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "[:team_affiliation_with_badges factory]" do
    subject { create( :team_affiliation_with_badges ) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "has a valid Team" do
      expect( subject.team ).to be_valid
    end
    it "has a valid Season" do
      expect( subject.season ).to be_valid
    end
    it "has a Season with several CategoryTypes" do
      expect( subject.season.category_types.count ).to be > 1
    end

    it "has more than 1 Badge" do
      expect( subject.team.badges.count ).to be > 1
    end
    it "has more than 1 Swimmer" do
      expect( subject.team.swimmers.count ).to be > 1
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "[TeamAffiliationFactoryTools.create_affiliation_with_badge_list()]" do
    subject do
      @team = create( :team )
      TeamAffiliationFactoryTools.create_affiliation_with_badge_list( @team, 3 )
    end

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "has a valid Team" do
      expect( subject.team ).to be_valid
    end
    it "linked to the specified Team" do
      expect( subject.team.id ).to eq( @team.id )
    end
    it "has a valid Season" do
      expect( subject.season ).to be_valid
    end
    it "has a Season with several CategoryTypes" do
      expect( subject.season.category_types.count ).to be > 1
    end

    it "has exactly 3 Badges" do
      expect( subject.team.badges.count ).to eq(3)
      expect( subject.badges.count ).to eq(3)
    end
    it "has exactly 3 Swimmers" do
      expect( subject.team.swimmers.count ).to eq(3)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
