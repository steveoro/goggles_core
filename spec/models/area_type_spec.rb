require 'rails_helper'

RSpec.describe AreaType, type: :model do
  context "[a well formed instance]" do

    subject { create(:area_type) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end

    context "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty strings)", [
        :get_name_with_code
      ])
    end
  end
end
