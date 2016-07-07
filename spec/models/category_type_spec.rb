require 'rails_helper'


describe CategoryType, :type => :model do
  it_behaves_like "DropDownListable"

  describe "[a non-valid instance]" do
    it_behaves_like( "(missing required values)", [ :code ])
  end

  describe "[a well formed instance]" do
    subject { create(:category_type) }

    context "[well formed category type instance]" do
      it "is a valid istance" do
        expect( subject ).to be_valid
      end
      it "has a valid season instance" do
        expect( subject.season ).to be_valid
      end
      it "has a valid season_type instance" do
        expect( subject.season_type ).to be_valid
      end
      it "has a valid federation_type instance" do
        expect( subject.federation_type ).to be_valid
      end

      it_behaves_like( "(belongs_to required models)", [
        :season
      ])
    end

    # Test the existance of all the required has_one relationships:
    it_behaves_like( "(it has_one of these required models)",
      [
        :season_type,
        :federation_type
      ]
    )

    # Filtering scopes:
    it_behaves_like( "(the existance of a class method)", [
      :is_valid,
      :only_relays,
      :are_not_relays
    ])

    # Other class methods:
    it_behaves_like( "(the existance of a class method)", [
      :parse_category_type_from_import_text
    ])

    context "[general methods]" do

      it_behaves_like( "(the existance of a method returning non-empty strings)", [
        :get_short_name,
        :get_full_name,
        :get_verbose_name
      ])

      it_behaves_like "(the existance of a method with parameters, returning boolean values)", [
        :is_age_in_category
      ],
      30
    end

    context "#is_age_in_category" do
      it "#is_age_in_category correctly evaluates age" do
        expect( subject.is_age_in_category(subject.age_begin + 1) ).to be true
        expect( subject.is_age_in_category(subject.age_begin - 5) ).to be false
        expect( subject.is_age_in_category(subject.age_end + 5) ).to be false
      end
    end

    describe "self.parse_category_type_from_import_text()" do
      subject { create( :category_type) }

      it "returns the corresponding category for the specified code" do
        result = CategoryType.parse_category_type_from_import_text(
          subject.season_id,
          subject.code
        )
        expect( result ).to eq( subject )
      end
      it "returns nil for an unknown code" do
        result = CategoryType.parse_category_type_from_import_text(
          create( :season ).id,
          'M20'
        )
        expect( result ).to be nil
      end
    end
  end
end
