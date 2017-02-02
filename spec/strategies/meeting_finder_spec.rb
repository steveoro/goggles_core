# encoding: utf-8
require 'rails_helper'

require 'meeting_finder'


describe MeetingFinder, type: :strategy do

  it_behaves_like( "(the existance of a method)", [
    :search_ids, :deep_search_ids, :search, :search_in_header, :search_in_swimming_pool, :search_in_teams, :search_in_swimmers
  ] )
  #-- -------------------------------------------------------------------------
  #++

  context "when no search term is supplied," do
    subject { MeetingFinder.new }

    describe "#search_ids" do
      it "returns all Meeting rows" do
        expect( subject.search_ids.size ).to eq( Meeting.count )
      end
    end
    describe "#deep_search_ids" do
      it "returns all Meeting rows" do
        expect( subject.deep_search_ids.size ).to eq( Meeting.count )
      end
    end
    describe "#search" do
      it "returns all Meeting rows" do
        expect( subject.search.count ).to eq( Meeting.count )
      end
    end
  end


  context "when an empty search term is supplied," do
    subject { MeetingFinder.new('') }

    describe "#search_ids" do
      it "returns all Meeting rows" do
        expect( subject.search_ids.size ).to eq( Meeting.count )
      end
    end
    describe "#deep_search_ids" do
      it "returns all Meeting rows" do
        expect( subject.deep_search_ids.size ).to eq( Meeting.count )
      end
    end
    describe "#search" do
      it "returns all Meeting rows" do
        expect( subject.search.count ).to eq( Meeting.count )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "when an existing search term is supplied," do
    subject { MeetingFinder.new("ravenna") }

    describe "#search_ids" do
      it "returns some Meeting rows" do
        result_count = subject.search_ids.size
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end
    end
    describe "#deep_search_ids" do
      it "returns some Meeting rows not less than search_ids" do
        result_count = subject.deep_search_ids.size
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
        expect( result_count ).to be >= subject.search_ids.size
      end
    end
    describe "#search" do
      it "returns more than 1 result with the existing seeds" do
        result_count = subject.search.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end
      it "returns a list of Meeting instances" do
        expect( subject.search ).to all be_an_instance_of( Meeting )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "when a non-existing search term is supplied," do
    subject { MeetingFinder.new("LARICIUMBALALLILLALLERO") }

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
  
  context "search methods," do
    subject { MeetingFinder.new("riccione") }

    describe "#search_in_header" do
      it "returns more than 1 result with the existing seeds" do
        result_count = subject.search_in_header.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end

      it "returns an empty list if event given" do
        no_header = MeetingFinder.new("200MI")
        result = no_header.search_in_header
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end

      it "returns an empty list if swimmer given" do
        no_header = MeetingFinder.new("MARCO LIGABUE")
        result = no_header.search_in_header
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end

      it "returns an empty list if team given" do
        no_header = MeetingFinder.new("ONDA DELLA PIETRA")
        result = no_header.search_in_header
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end
    end

    describe "#search_in_swimming_pool" do
      it "returns more than 1 result with the existing seeds" do
        result_count = subject.search_in_swimming_pool.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end

      it "returns an empty list if event given" do
        no_pool = MeetingFinder.new("200MI")
        result = no_pool.search_in_swimming_pool
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end

      it "returns an empty list if swimmer given" do
        no_pool = MeetingFinder.new("MARCO LIGABUE")
        result = no_pool.search_in_swimming_pool
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end

      it "returns an empty list if header given" do
        no_pool = MeetingFinder.new("MEETING")
        result = no_pool.search_in_swimming_pool
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end
    end

    describe "#search_in_teams" do
      it "returns more than 1 result with the existing seeds" do
        result_count = subject.search_in_teams.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end
    end

    describe "#search_in_swimmers" do
      it "returns more than 1 result with the existing seeds" do
        ok_swimmer = MeetingFinder.new("LIGABUE")
        result_count = subject.search_in_swimmers.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end
    end
  end
end
