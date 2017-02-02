# encoding: utf-8
require 'rails_helper'

require 'meeting_finder'


describe MeetingFinder, type: :strategy do

  it_behaves_like( "(the existance of a method)", [
    :search_ids, :deep_search_ids, :search, :search_in_header, :search_in_events, :search_in_swimming_pool, :search_in_teams, :search_in_swimmers, :find_event_types
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
    # TODO Use some random values
    let( :meeting_name ) { 'RICCIONE' }
    let( :city_name )    { 'RICCIONE' }
    let( :pool_name )    { 'STADIO DEL NUOTO' }
    let( :event_name )   { '1500' }
    let( :team_name )    { 'TIBIDABO' }
    let( :swimmer_name ) { 'MARCO LIGABUE' }
    
    let( :on_meetings )  { MeetingFinder.new( meeting_name ) }
    let( :on_cities )    { MeetingFinder.new( city_name ) }
    let( :on_pools )     { MeetingFinder.new( pool_name ) }
    let( :on_events )    { MeetingFinder.new( event_name ) }
    let( :on_teams )     { MeetingFinder.new( team_name ) }
    let( :on_swimmers )  { MeetingFinder.new( swimmer_name ) }

    describe "#search_in_header" do
      it "returns more than 1 result if meeting given" do
        result_count = on_meetings.search_in_header.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end

      it "returns an empty list if event given" do
        result = on_events.search_in_header
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end

      it "returns an empty list if team given" do
        result = on_teams.search_in_header
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end

      it "returns an empty list if swimmer given" do
        result = on_swimmers.search_in_header
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end
    end

    describe "#find_event_types" do
      it "returns more than 1 result if event given" do
        result_count = on_events.find_event_types.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < EventType.count
      end

      it "returns an empty list if meeting given" do
        result = on_meetings.find_event_types
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end
    end

    describe "#search_in_events" do
      it "returns more than 1 result if event given" do
        result_count = on_events.search_in_events.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end

      it "returns an empty list if meeting given" do
        result = on_meetings.search_in_events
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end

      it "returns an empty list if city given" do
        result = on_cities.search_in_events
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end

      it "returns an empty list if team given" do
        result = on_teams.search_in_events
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end

      it "returns an empty list if swimmer given" do
        result = on_swimmers.search_in_events
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end
    end

    describe "#search_in_swimming_pool" do
      it "returns more than 1 result if pool given" do
        result_count = on_pools.search_in_swimming_pool.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end

      it "returns more than 1 result if city given" do
        result_count = on_cities.search_in_swimming_pool.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end

      it "returns an empty list if event given" do
        result = on_events.search_in_swimming_pool
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end

      it "returns an empty list if team given" do
        result = on_teams.search_in_swimming_pool
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end

      it "returns an empty list if swimmer given" do
        result = on_swimmers.search_in_swimming_pool
        expect( result ).to respond_to(:each)
        expect( result ).to respond_to(:size)
        expect( result.size ).to eq( 0 )
      end
    end

    describe "#search_in_teams" do
      it "returns more than 1 result if team given" do
        result_count = on_teams.search_in_teams.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end
    end

    describe "#search_in_swimmers" do
      it "returns more than 1 result if swimmer given" do
        result_count = on_swimmers.search_in_swimmers.count
        expect( result_count ).to be > 0
        expect( result_count ).to be < Meeting.count
      end
    end
  end
end
