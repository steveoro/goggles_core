require 'rails_helper'

describe SwimmingPoolReview, :type => :model do

  context "[a well formed instance]" do
    subject { create(:swimming_pool_review) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end

    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :swimming_pool
    ])    

    context "[general methods]" do
      it_behaves_like( "(the existance of a method)", [
        :get_full_name, 
        :get_verbose_name,
        :user_name
      ])
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
