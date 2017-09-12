require 'rails_helper'


describe DataImportBadge, :type => :model do
  describe "[a non-valid instance]" do
    it_behaves_like( "(missing required values)", [ :number ])
  end
  #-- -------------------------------------------------------------------------
  #++

  context "[a well formed instance]" do
    subject { create(:data_import_badge) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :team,
      :season,
      :swimmer,
      :category_type,
      :entry_time_type
    ])
  end
  #-- -------------------------------------------------------------------------
  #++
end
