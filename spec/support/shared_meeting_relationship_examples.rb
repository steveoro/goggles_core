require 'rails_helper'


shared_examples_for "a valid instance having a valid Season, Meeting and Team (+Affiliation)" do
  it "is a valid istance" do
    expect( subject ).to be_valid
  end
  it "has a valid Team instance" do
    expect( subject.team ).to be_valid
  end
  it "has a valid TeamAffiliation instance" do
    expect( subject.team ).to be_valid
  end
  it "has a valid Season instance" do
    expect( subject.season ).to be_valid
  end
  it "has a valid Meeting instance" do
    expect( subject.meeting ).to be_valid
  end

  # Validated relations:
  it_behaves_like( "(belongs_to required models)", [
    :team,
    :team_affiliation,
    :meeting,
    :season
  ])
end
#-- ---------------------------------------------------------------------------
#++
