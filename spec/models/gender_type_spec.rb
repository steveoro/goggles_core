require 'rails_helper'
require 'ffaker'


describe GenderType, :type => :model do
  it_behaves_like "DropDownListable"
  it_behaves_like "Localizable"

  it_behaves_like( "(the existance of a class method)", [
    :parse_gender_type_from_import_text
  ])

  it_behaves_like( "(the existance of a method)", [
    :is_male,
    :is_female
  ])


  describe "self.parse_gender_type_from_import_text()" do
    it "returns a male GenderType instance for token 'maschi'" do
      result = GenderType.parse_gender_type_from_import_text( 'maschi' )
      expect( result ).to be_an_instance_of( GenderType )
      expect( result.is_male ).to be true
      expect( result.is_female ).to be false
    end
    it "returns a female GenderType instance for token 'femmi'" do
      result = GenderType.parse_gender_type_from_import_text( 'femmi' )
      expect( result ).to be_an_instance_of( GenderType )
      expect( result.is_female ).to be true
      expect( result.is_male ).to be false
    end

    it "returns a non-specific GenderType instance for any other token" do
      result = GenderType.parse_gender_type_from_import_text( FFaker::Lorem.word )
      expect( result ).to be_an_instance_of( GenderType )
      expect( result.is_female ).to be false
      expect( result.is_male ).to be false
    end
  end
end
