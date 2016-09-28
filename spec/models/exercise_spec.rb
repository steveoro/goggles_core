require 'rails_helper'


describe Exercise, type: :model do
  context "[a well formed instance]" do
    subject { Exercise.all.sort{ rand - 0.5 }[0] }

    it_behaves_like "DropDownListable"

    it "is a not nil" do
      expect( subject ).not_to be_nil
    end
    it "is a valid istance" do
      expect( subject ).to be_valid
    end


    context "[implemented methods]" do
      it_behaves_like( "(the existance of a class method)",
        [
          :belongs_to_training_step_code,
          :get_label_symbol
        ]
      )
      it_behaves_like( "(the existance of a method)",
        [
          :get_full_name
        ]
      )
      it_behaves_like( "(the existance of a method returning a boolean value)",
        [
          :is_arm_aux_allowed,
          :is_kick_aux_allowed,
          :is_body_aux_allowed,
          :is_breath_aux_allowed
        ]
      )
      it_behaves_like( "(the existance of a method returning numeric values)",
        [
          :compute_total_distance,
          :compute_total_seconds
        ]
      )
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "self.belongs_to_training_step_code()" do
    let(:result) { subject.class.belongs_to_training_step_code(1) }

    it "returns a scoped enumberable of rows" do
      expect( result ).to be_a_kind_of( Enumerable )
      result.each { |row| expect( row ).to be_a_kind_of( Exercise ) }
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # This is an integration to the standard DropDownListable specs:
  describe "self.to_dropdown()" do
    context "when using #get_friendly_description as label method," do
      let(:result) { Exercise.to_dropdown( nil, :id, :get_friendly_description ) }

      it "returns an Array of Arrays" do
        expect( result ).to be_an( Array )
        expect( result ).to all be_an( Array )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#compute_total_distance" do
    it "returns 0 or a positive number" do
      expect( subject.compute_total_distance ).to be >= 0
    end
  end

  describe "#compute_total_seconds" do
    it "returns 0 or a positive number" do
      expect( subject.compute_total_seconds ).to be >= 0
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#drop_down_attrs" do
    it "returns an Hash with the expected structure" do
      expect( subject.drop_down_attrs ).to be_an( Hash )
      expect( subject.drop_down_attrs.keys ).to include(
        :label, :value, :tot_distance, :tot_secs,
        :is_arm_aux_allowed, :is_kick_aux_allowed,
        :is_body_aux_allowed, :is_breath_aux_allowed
      )
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#get_full_name" do
    it "returns a String" do
      expect( subject.get_full_name ).to be_a( String )
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#get_friendly_description" do
    it "returns a String" do
      expect( subject.get_friendly_description ).to be_a( String )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
