require 'rails_helper'
require 'ffaker'


describe StrokeType, :type => :model do

  it_behaves_like( "(the existance of a class method)", [
    :is_eventable,
    :parse_stroke_type_from_import_text
  ])

  it_behaves_like( "(the existance of a method returning non-empty strings)", [
    :i18n_short, :i18n_description
  ])


  describe "self.parse_stroke_type_from_import_text()" do
    subject { StrokeType.all.sort{ rand - 0.5 }[0] }

    it "returns the StrokeType instance with FREESTYLE_ID for token 'stile'" do
      result = StrokeType.parse_stroke_type_from_import_text( 'stile' )
      expect( result ).to be_an_instance_of( StrokeType )
      expect( result.id ).to eq( StrokeType::FREESTYLE_ID )
    end
    it "returns the StrokeType instance with BUTTERFLY_ID for token 'farf'" do
      result = StrokeType.parse_stroke_type_from_import_text( 'farf' )
      expect( result ).to be_an_instance_of( StrokeType )
      expect( result.id ).to eq( StrokeType::BUTTERFLY_ID )
    end
    it "returns the StrokeType instance with BACKSTROKE_ID for token 'dorso'" do
      result = StrokeType.parse_stroke_type_from_import_text( 'dorso' )
      expect( result ).to be_an_instance_of( StrokeType )
      expect( result.id ).to eq( StrokeType::BACKSTROKE_ID )
    end
    it "returns the StrokeType instance with BREASTSTROKE_ID for token 'rana'" do
      result = StrokeType.parse_stroke_type_from_import_text( 'rana' )
      expect( result ).to be_an_instance_of( StrokeType )
      expect( result.id ).to eq( StrokeType::BREASTSTROKE_ID )
    end
    it "returns the StrokeType instance with MIXED_ID for token 'mist'" do
      result = StrokeType.parse_stroke_type_from_import_text( 'mist' )
      expect( result ).to be_an_instance_of( StrokeType )
      expect( result.id ).to eq( StrokeType::MIXED_ID )
    end

    it "returns nil for an unknown code" do
      result = StrokeType.parse_stroke_type_from_import_text( "#{(rand * 100).to_i} DummyStyle" )
      expect( result ).to be nil
    end
  end
end
