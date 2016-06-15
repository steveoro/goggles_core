# encoding: utf-8
require 'spec_helper'

require 'swimming_pool_finder'


describe SwimmingPoolFinder, type: :strategy do

  it_behaves_like( "(the existance of a method)", [
    :search_ids, :search
  ] )
  #-- -------------------------------------------------------------------------
  #++

  context "when no search term is supplied," do
    subject { SwimmingPoolFinder.new }

    describe "#search_ids" do
      it "returns an empty list" do
        expect( subject.search_ids.size ).to eq( 0 )
      end
    end
    describe "#search" do
      it "returns an empty list" do
        expect( subject.search.count ).to eq( 0 )
      end
    end
  end


  context "when an empty search term is supplied," do
    subject { SwimmingPoolFinder.new('') }

    describe "#search_ids" do
      it "returns an empty list" do
        expect( subject.search_ids.size ).to eq( 0 )
      end
    end
    describe "#search" do
      it "returns an empty list" do
        expect( subject.search.count ).to eq( 0 )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "when an existing search term ('reggio') is supplied," do
    subject { SwimmingPoolFinder.new("reggio") }

    describe "#search_ids" do
      it "returns at least >2 SwimmingPool rows with the existing seeds" do
        result_count = subject.search_ids.size
        expect( result_count ).to be > 2
        expect( result_count ).to be < SwimmingPool.count
      end
    end
    describe "#search" do
      it "returns at least >2 SwimmingPool rows with the existing seeds" do
        result_count = subject.search.count
        expect( result_count ).to be > 2
        expect( result_count ).to be < SwimmingPool.count
      end
      it "returns a list of SwimmingPool instances" do
        expect( subject.search ).to all be_an_instance_of( SwimmingPool )
      end
    end
  end


  context "when an existing search term ('melato') is supplied," do
    subject { SwimmingPoolFinder.new("melato") }

    describe "#search_ids" do
      it "returns at least a SwimmingPool row with the existing seeds" do
        result_count = subject.search_ids.size
        expect( result_count ).to be > 0
        expect( result_count ).to be < SwimmingPool.count
      end
    end
    describe "#search" do
      it "returns at least a SwimmingPool row with the existing seeds" do
        result_count = subject.search.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < SwimmingPool.count
      end
      it "returns a list of SwimmingPool instances" do
        expect( subject.search ).to all be_an_instance_of( SwimmingPool )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "when a non-existing search term is supplied," do
    subject { SwimmingPoolFinder.new("LARICIUMBALALLILLALLERO") }

    describe "#search_ids" do
      it "returns an empty list" do
        result = subject.search_ids
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end
    end
    describe "#search" do
      it "returns an empty list" do
        result = subject.search
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
