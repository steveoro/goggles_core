require 'rails_helper'


shared_examples_for "Localizable" do

  # Describes the requistes of the including class
  # and the outcome of the module inclusion.
  #
  context "by including this concern" do
    it_behaves_like( "(the existance of a class method)", [ :table_name ] )
    it_behaves_like( "(the existance of a method)",
      [
        :code, 
        :i18n_short,
        :i18n_description,
        :i18n_alternate
      ]
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#i18n_short" do
    it "returns always a non-empty string" do
      expect( subject.i18n_short ).not_to eq( '' )
      expect( subject.i18n_short.size ).to be > 0
    end
  end

  describe "#i18n_description" do
    it "returns always a non-empty string" do
      expect( subject.i18n_description ).not_to eq( '' )
      expect( subject.i18n_description.size ).to be > 0
    end
  end

  describe "#i18n_alternate" do
    it "returns always a non-empty string" do
      expect( subject.i18n_alternate ).not_to eq( '' )
      expect( subject.i18n_alternate.size ).to be > 0
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
