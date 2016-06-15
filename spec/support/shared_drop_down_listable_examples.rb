require 'spec_helper'


shared_examples_for "DropDownListable" do

  # Describes the requisites of the including class
  # and the outcome of the module inclusion.
  #
  context "by including this concern" do
    it_behaves_like( "(the existance of a class method)", [ :get_label_symbol, :to_dropdown, :to_unsorted_dropdown ] )
    it_behaves_like( "(the existance of a method)", [ :id ] )
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#get_label_symbol()" do
    it "always returns a Symbol" do
      expect( subject.class.get_label_symbol() ).to be_an_instance_of( Symbol )
    end
    it "refers to an existing method" do
      method_sym = subject.class.get_label_symbol()
      expect( subject ).to respond_to( method_sym )
    end
  end

  describe "#to_dropdown()" do
    it "always returns an array" do
      result = subject.class.to_dropdown()
      expect( result ).to be_an_instance_of( Array )
    end
  end

  describe "#to_unsorted_dropdown()" do
    it "always returns an array" do
      result = subject.class.to_unsorted_dropdown()
      expect( result ).to be_an_instance_of( Array )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
