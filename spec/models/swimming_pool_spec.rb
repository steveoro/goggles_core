require 'rails_helper'


describe SwimmingPool, :type => :model do
  describe "[a non-valid instance]" do
    it_behaves_like( "(missing required values)", [ 
      :name,
      :nick_name,
      :lanes_number
    ])
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "[a well formed instance]" do
    subject { create(:swimming_pool) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [ 
      :city,
      :pool_type
    ])    

    it "has a valid city" do
      expect( subject.city ).to be_an_instance_of( City )
    end
    it "has a valid pool type" do
      expect( subject.pool_type ).to be_an_instance_of( PoolType )
    end

    context "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty strings)", [ 
        :get_full_name,
        :get_verbose_name,
        :user_name
      ])
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
