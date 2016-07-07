# encoding: utf-8

require 'rails_helper'

describe SeasonPonderatedBestsDAO, type: :model do
  let(:season)              { Season.find(141) }
  let(:gender_type)         { GenderType.individual_only[ ((rand * GenderType.individual_only.count) % GenderType.individual_only.count).to_i ] }
  let(:category_type)       { season.category_types[ ((rand * season.category_types.count) % season.category_types.count).to_i ] }
  let(:event_type)          { season.event_types[ ((rand * season.event_types.count) % season.event_types.count).to_i ] }
  let(:pool_type)           { PoolType.find_by_code('25') }  # FIXME Randomize
  
  let(:sure_event_type)     { EventType.find_by_code('50SL') }
  let(:sure_pool_type)      { PoolType.find_by_code('25') }
  let(:sure_category_type)  { season.category_types.find_by_code('M25') }

  let(:empty_event_type)    { EventType.find_by_code('100MI') }
  let(:empty_pool_type)     { PoolType.find_by_code('50') }
  let(:empty_category_type) { season.category_types.find_by_code('M50') }
  
  let(:max_results)         { ((rand * 3) % 3).to_i + 3 }
  let(:bests_to_be_ignored) { 1 }

  context "EventPonderatedBestDAO subclass," do

    subject { SeasonPonderatedBestsDAO::EventPonderatedBestDAO.new( season, gender_type, category_type, event_type, pool_type, max_results, bests_to_be_ignored ) }

    it_behaves_like( "(the existance of a method)", [
      :season, :season_type, :gender_type, :category_type, :event_type, :pool_type, 
      :best_results, :total_results, 
      :get_max_results, :get_bests_to_be_ignored,
      :collect_event_bests, :set_ponderated_best, :get_ponderated_best
    ] )

    describe "#season" do
      it "is the season used in construction" do
        expect( subject.season ).to eq( season )
      end
    end
    describe "#season_type" do
      it "is the season type of the season used in construction" do
        expect( subject.season_type ).to eq( season.season_type )
      end
    end
    describe "#gender_type" do
      it "is the gender type used in construction" do
        expect( subject.gender_type ).to eq( gender_type )
      end
    end
    describe "#category_type" do
      it "is the category type used in construction" do
        expect( subject.category_type ).to eq( category_type )
      end
    end
    describe "#event_type" do
      it "is the event type used in construction" do
        expect( subject.event_type ).to eq( event_type )
      end
    end
    describe "#pool_type" do
      it "is the pool type used in construction" do
        expect( subject.pool_type ).to eq( pool_type )
      end
    end
    #-- -------------------------------------------------------------------------
    #++
    
    describe "#best_results" do
      it "is a collection of best meeting individal results to considered for the event" do
        expect( subject.best_results ).to be_a_kind_of( ActiveRecord::Relation )
        expect( subject.best_results ).to all(be_an_instance_of( MeetingIndividualResult ))
      end
    end
    describe "#total_results" do
      it "is a valid number" do
        expect( subject.total_results ).to be >= 0
      end
    end
    #-- -------------------------------------------------------------------------
    #++

    describe "#get_max_results" do
      it "is a valid number" do
        expect( subject.get_max_results ).to be >= 0
      end
    end
    describe "#get_bests_to_be_ignored" do
      it "is a valid number" do
        expect( subject.get_bests_to_be_ignored ).to be >= 0
      end
    end
    #-- -------------------------------------------------------------------------
    #++

    context "as a valid instance" do
      # Ensure there are times swam
      subject { SeasonPonderatedBestsDAO::EventPonderatedBestDAO.new( season, gender_type, sure_category_type, sure_event_type, sure_pool_type, max_results, bests_to_be_ignored ) }

      describe "#collect_event_bests" do
        it "it collects the first given number of best results for the event" do
          expect( subject.best_results.count ).to be > 0
          expect( subject.best_results.count ).to be <= (max_results + bests_to_be_ignored)
        end
      end
      #-- -------------------------------------------------------------------------
      #++

      describe "#set_ponderated_best" do
        it "it sets the value of ponderated best time for the event" do
          expect( subject.get_ponderated_best ).to be_an_instance_of( Timing )
          expect( subject.get_ponderated_best ).to be >= subject.best_results.first.get_timing_instance
          expect( subject.get_ponderated_best ).to be <= subject.best_results.last.get_timing_instance
        end
      end
      #-- -------------------------------------------------------------------------
      #++

      describe "#get_ponderated_best" do
        context "with bests collected" do
          it "returns the value of ponderated best time for the event" do
            expect( subject.get_ponderated_best ).to be_an_instance_of( Timing )
          end
        end

        context "without bests collected" do
          # Ensure there are times swam
          subject { SeasonPonderatedBestsDAO::EventPonderatedBestDAO.new( season, gender_type, empty_category_type, empty_event_type, empty_pool_type, max_results, bests_to_be_ignored ) }

          it "returns nil" do
            expect( subject.get_ponderated_best ).to be_an_instance_of( Timing )
            expect( subject.get_ponderated_best ).to eq( Timing.new() )
          end
        end
      end
      #-- -------------------------------------------------------------------------
      #++
    end    
    
  end
  #-- -------------------------------------------------------------------------
  #++


  context "as a valid instance," do

    subject { SeasonPonderatedBestsDAO.new( season, max_results, bests_to_be_ignored ) }

    it_behaves_like( "(the existance of a method)", [
      :season, :single_events, :insert_events, :update_events, :max_results, :bests_to_be_ignored, :event_types, :categories, 
      :find_season_type_events, :find_season_type_category_codes, :scan_for_gender_category_and_event
    ] )

    describe "#season" do
      it "is the season specified for the construction" do
        expect( subject.season ).to eq( season )
      end
    end
    describe "#single_events" do
      it "is a collection of EventTargetTimeDAO" do
        expect( subject.single_events ).to be_a_kind_of( Enumerable )
        expect( subject.single_events ).to all(be_a_kind_of( SeasonPonderatedBestsDAO::EventPonderatedBestDAO ))
      end
    end
    describe "#insert_events" do
      it "is a collection of EventTargetTimeDAO" do
        expect( subject.insert_events ).to be_a_kind_of( Enumerable )
        expect( subject.insert_events ).to all(be_a_kind_of( SeasonPonderatedBestsDAO::EventPonderatedBestDAO ))
      end
    end
    describe "#update_events" do
      it "is a collection of EventTargetTimeDAO" do
        expect( subject.update_events ).to be_a_kind_of( Enumerable )
        expect( subject.update_events ).to all(be_a_kind_of( SeasonPonderatedBestsDAO::EventPonderatedBestDAO ))
      end
    end
    describe "#max_results" do
      it "is the maximum number of best results used in construction" do
        expect( subject.max_results ).to eq( max_results )
      end
    end
    describe "#bests_to_be_ignored" do
      it "is the number of best results to be ignored used in construction" do
        expect( subject.bests_to_be_ignored ).to eq( bests_to_be_ignored )
      end
    end
    describe "#event_types" do
      it "is a collection of event types" do
        expect( subject.event_types ).to be_a_kind_of( ActiveRecord::Relation )
        expect( subject.event_types ).to all(be_a_kind_of( EventType ))
      end
    end
    describe "#categories" do
      it "is a collection of category codes" do
        found_cat = subject.categories
        expect( found_cat ).to be_a_kind_of( Enumerable )
        found_cat.each do |category_code|
          expect( CategoryType.find_by_code(category_code) ).to be_an_instance_of( CategoryType )  
        end
      end
    end

    describe "#find_season_type_events" do
      it "returns a collection of at least one event types" do
        subject.find_season_type_events
        expect( subject.event_types.count ).to be > 0
        expect( subject.event_types ).to all(be_a_kind_of( EventType ))
      end
    end
    describe "#find_season_type_category_codes" do
      it "returns a collection of category codes" do
        found_cat = subject.find_season_type_category_codes
        expect( found_cat.size ).to be > 0
        found_cat.each do |category_code|
          expect( CategoryType.find_by_code(category_code) ).to be_an_instance_of( CategoryType )  
        end
      end
    end

    describe "#scan_for_gender_category_and_event" do
      it "returns a collection of EventTargetTimeDAO" do
        subject.scan_for_gender_category_and_event
        expect( subject.single_events.size ).to be >= 0
        expect( subject.single_events ).to all(be_a_kind_of( SeasonPonderatedBestsDAO::EventPonderatedBestDAO ))
      end
    end

    describe "#prepare_to_store" do
      it "returns true" do
        expect( subject.prepare_to_store ).to be true
      end
      it "populates insert and/or update arrays" do
        expect( subject.insert_events.size ).to eq( 0 )
        expect( subject.update_events.size ).to eq( 0 )
        subject.prepare_to_store
        expect( subject.insert_events.size + subject.update_events.size ).to be >= 0
        expect( subject.insert_events.size + subject.update_events.size ).to eq( subject.single_events.size )
      end
    end

    describe "#to_db" do
      it "stores on DB each single event" do
        subject.to_db
        subject.single_events.each do |event|
          expect( TimeStandard.exists?( :season => season, :gender_type => event.gender_type, :category_type => event.category_type, :pool_type => event.pool_type, :event_type => event.event_type ) ).to be true
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "not a valid instance" do
    it "raises an exception for wrong season parameter" do
      expect{ SeasonPonderatedBestsDAO.new( 'Wrong parameter' ) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end

