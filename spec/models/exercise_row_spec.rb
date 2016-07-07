require 'rails_helper'


describe ExerciseRow, :type => :model do
  context "[a well formed instance]" do
    subject { ExerciseRow.all.sort{ rand - 0.5 }[0] }

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
          :get_label_symbol,
          :esteem_time_in_seconds
        ]
      )
      it_behaves_like( "(the existance of a method)",
        [
          :get_full_name
        ]
      )
      it_behaves_like( "(the existance of a method returning numeric values)",
        [
          :compute_total_seconds
        ]
      )
      it_behaves_like( "(the existance of a method returning strings)",
        [
          :compute_displayable_distance,
        ]
      )
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "self.esteem_time_in_seconds()" do
    let(:result) { subject.class.esteem_time_in_seconds( (rand * 1000 % 50).to_i * 50 ) }

    it "returns an integer number of seconds" do
      expect( result ).to be_a_kind_of( Integer )
    end
    it "returns a zero or a positive number of seconds" do
      expect( result ).to be >= 0
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#compute_total_seconds" do
    let(:inline_fixture) { ExerciseRow.new( part_order: 1, distance: 100, pause: 10 ) }

    it "returns 0 or a positive number" do
      expect( subject.compute_total_seconds ).to be >= 0
    end
    it "returns the total seconds when using start_and_rest" do
      inline_fixture.start_and_rest = 100
      expect( inline_fixture.compute_total_seconds ).to be == 100
    end
    it "returns the esteemed seconds when using pause" do
      inline_fixture.start_and_rest = 0
      expect( inline_fixture.compute_total_seconds(true) ).to be >= 130
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#compute_displayable_distance" do
    let(:inline_fixture) { ExerciseRow.new( part_order: 1, percentage: 50, pause: 10 ) }

    it "returns the distance by default" do
      inline_fixture.distance = 100
      expect( inline_fixture.compute_displayable_distance ).to eq('100')
    end
    it "returns the percentage of the total distance when using total_distance" do
      inline_fixture.distance = 0
      expect( inline_fixture.compute_displayable_distance(300) ).to eq('150')
    end
    it "returns just the percentage when not using total_distance" do
      inline_fixture.distance = 0
      expect( inline_fixture.compute_displayable_distance() ).to eq('50%')
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
