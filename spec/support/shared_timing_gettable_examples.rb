require 'spec_helper'
require 'wrappers/timing'


shared_examples_for "TimingGettable" do

  # Describes the requistes of the including class
  # and the outcome of the module inclusion.
  #
  context "by including this concern" do
    it_behaves_like( "(the existance of a method)",
      [
        :minutes, 
        :seconds,
        :hundreds,
        :get_timing,
        :get_timing_instance
      ]
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Describes the required functionalities of this method
  # of the interface.
  #
  describe "#get_timing" do
    it "returns always a non-empty string" do
      expect( subject.get_timing ).not_to eq( '' )
      expect( subject.get_timing.size ).to be > 0
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Describes the required functionalities of this method
  # of the interface.
  #
  describe "#get_timing_instance" do
    it "returns always a Timing instance" do
      expect( subject.get_timing_instance ).to be_an_instance_of( Timing )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
