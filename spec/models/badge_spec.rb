require 'spec_helper'


describe Badge, :type => :model do
  describe "[a non-valid instance]" do
    it_behaves_like( "(missing required values)", [ :number ])
  end
  #-- -------------------------------------------------------------------------
  #++

  context "[a well formed instance]" do
    subject { create(:badge) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :team,
      :season,
      :swimmer,
      :team_affiliation,
      :category_type,
      :entry_time_type
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
end
