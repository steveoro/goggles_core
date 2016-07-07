require 'rails_helper'


describe GoggleCupDefinition, :type => :model do
  describe "[a well formed instance]" do
    subject { create( :goggle_cup_definition ) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    
    # Validated (owned foreign-key) relations:
    it_behaves_like( "(belongs_to required models)", [
       :goggle_cup,
       :season
    ])
    
    # Test the existance of all the required has_many / has_one relationships:
    it_behaves_like( "(it has_one of these required models)", [ 
      :team
    ])    

    # Filtering scopes:
    it_behaves_like( "(the existance of a class method)", [
      :sort_by_begin_date,
      :sort_by_end_date
    ])
  end
  #-- -------------------------------------------------------------------------
  #++
end
