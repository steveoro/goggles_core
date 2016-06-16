require 'rails_helper'


RSpec.describe TeamManager, :type => :model do

  subject { create( :team_manager ) }

  describe "[a well formed instance]" do
    it "is a valid istance" do
      expect( subject ).to be_valid
    end

    # Validated (owned foreign-key) relations:
    it_behaves_like( "(belongs_to required models)", [ :user, :team_affiliation ] )

    context "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty strings)",
        [
          :user_name
        ]
      )
    end
    # ---------------------------------------------------------------------------
    #++
  end
end
