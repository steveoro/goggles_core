# encoding: utf-8

require 'rails_helper'

describe SeasonalEventBestDAO, type: :model do
  let(:season)        { Season.find(141) }
  let(:gender_type)   { GenderType.individual_only.sample }
  let(:category_type) { season.category_types.are_not_relays.sample }
  let(:event_type)    { season.event_types.reject{|et| et.is_a_relay }.sample }

#  let(:relay_category_type) { season.category_types.only_relays.sample }
#  let(:relay_event_type)    { season.event_types.only_relays.sample }

  let(:is_converted)  { [true, false].sample }
  let(:total_events)  { (2..4).to_a.sample }
  let(:events_swam)   { (1..total_events).to_a.sample }
  let(:time_swam)     { ((rand * 15000) % 15000).to_i + 1 }

  context "SingleEventBestDAO subclass," do

    subject { SeasonalEventBestDAO::SingleEventBestDAO.new( gender_type, category_type, event_type, time_swam, is_converted, total_events, events_swam ) }

    it_behaves_like( "(the existance of a method)", [
      :gender_type, :category_type, :event_type, :time_swam, :is_converted, :total_events, :events_swam
    ] )

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
    describe "#is_converted" do
      it "is the is_converted flag used in construction" do
        expect( subject.is_converted ).to eq( is_converted )
      end
    end
    describe "#total_events" do
      it "is the total events value used in construction" do
        expect( subject.total_events ).to eq( total_events )
      end
    end
    describe "#events_swam" do
      it "is the events swam value used in construction" do
        expect( subject.events_swam ).to eq( events_swam )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  context "as a valid instance," do

    subject { SeasonalEventBestDAO.new( season ) }

    it_behaves_like( "(the existance of a method)", [
      :season, :event_bests, :timing_converter, :calculate_event_best, :scan_for_gender_category_and_event, :set_best_for_gender_category_and_event, :get_best_for_gender_category_and_event
    ] )

    describe "#season" do
      it "is the season specified for the construction" do
        expect( subject.season ).to eq( season )
      end
    end
    describe "#event_bests" do
      it "is a collection of SingleEventBestDAO" do
        expect( subject.event_bests ).to be_a_kind_of( Enumerable )
        expect( subject.event_bests ).to all(be_a_kind_of( SeasonalEventBestDAO::SingleEventBestDAO ))
      end
    end
    describe "#timing_converter" do
      it "is an instance of TimingCourseConverter" do
        expect( subject.timing_converter ).to be_an_instance_of( TimingCourseConverter )
      end
    end


    describe "#calculate_event_best" do
      it "returns an event best or nil" do
        expect( subject.calculate_event_best( gender_type, category_type, event_type, total_events, events_swam ) ).to be_a_kind_of( SeasonalEventBestDAO::SingleEventBestDAO ).or be_nil
      end
      it "returns an event best for 50SL Male M25" do
        expect( subject.calculate_event_best( GenderType.find_by_code("M"), season.category_types.find_by_code("M25"), EventType.find_by_code("50SL"), total_events, events_swam ) ).to be_a_kind_of( SeasonalEventBestDAO::SingleEventBestDAO )
      end
      it "returns an event best for 100SL Male M25 slower than 50SL Male M25" do
        event_best_50 = subject.calculate_event_best( GenderType.find_by_code("M"), season.category_types.find_by_code("M25"), EventType.find_by_code("50SL"), total_events, events_swam )
        expect( subject.calculate_event_best( GenderType.find_by_code("M"), season.category_types.find_by_code("M25"), EventType.find_by_code("100SL"), total_events, events_swam ).time_swam.to_hundreds ).to be > event_best_50.time_swam.to_hundreds
      end

      it "returns a value smaller than other of same gender, category and event" do
        mirs = MeetingIndividualResult.is_valid
              .joins(:meeting_program, :meeting_event, :meeting_session, :meeting)
              .includes(:meeting_program, :meeting_event, :meeting)
              .where( 'meetings.season_id = ?', season.id )
              .where( 'meeting_programs.gender_type_id = ?', gender_type.id )
              .where( 'meeting_programs.category_type_id = ?', category_type.id )
              .where( 'meeting_events.event_type_id = ?', event_type.id )
        best_calculated = subject.calculate_event_best(
          gender_type,
          category_type,
          event_type,
          total_events,
          events_swam
        )
# DEBUG
        puts "\r\n***********************************************************************************"
        if best_calculated.nil?
          puts "\r\n=> seasonal_event_best_dao_spec, #100:"
          puts "- gender: #{gender_type.inspect }"
          puts "- category: #{ category_type.inspect }"
          puts "- event: #{ event_type.inspect }"
          puts "- total_events: #{ total_events }, events_swam: #{ events_swam }"
          puts "\r\nLeega: YOU HAVE NIL RESULTS FROM #calculate_event_best (usually a relay is the culprit),"
          puts "== FIX IT or CHANGE THIS SPEC! =="
          puts "\r\n***********************************************************************************"
        else
# DEBUG
          puts "- best_calculated: #{ best_calculated.time_swam } (#{ best_calculated.time_swam.class.name })\r\n"
          puts "- gender: #{gender_type.code }, category: #{ category_type.code }, event: #{ event_type.code }"
          puts "- total_events: #{ total_events }, events_swam: #{ events_swam }\r\nCandidate MIRs:"

          equivalent_mirs = mirs.map do |mir|
            timing = mir.pool_type.code == '50' ?
                subject.timing_converter.convert_time_to_short( mir.get_timing_instance, gender_type, event_type ) :
                mir.get_timing_instance
# DEBUG
            puts "- ID: #{ mir.id } => #{ mir.get_timing(true) }, converted: #{ timing } (from: #{ mir.class.name }, pool: #{ mir.pool_type.code })"
            timing
          end

          expect( equivalent_mirs ).to all be >= best_calculated.time_swam
        end

=begin OLD CONFUSING VERSION:
        mirs.each do |mir|
          time_swam = (
            mir.pool_type.code == '50' ?
            subject.timing_converter.convert_time_to_short( mir.get_timing_instance, gender_type, event_type ) :
            mir.get_timing_instance
          )
          expect( time_swam.to_hundreds ).to be >= best_calculated.to_hundreds
        end
=end
      end
    end


    describe "#set_best_for_gender_category_and_event" do
      it "increments the event bests calculated" do
        subject.event_bests.clear
        prev_events = subject.event_bests.size
        subject.set_best_for_gender_category_and_event(
          GenderType.find_by_code("M"),
          season.category_types.find_by_code("M25"),
          EventType.find_by_code("50SL"),
          total_events,
          events_swam
        )
        expect( subject.event_bests.size ).to be > prev_events
      end
    end

    describe "#get_best_for_gender_category_and_event" do
      it "returns an event best" do
        subject.event_bests.clear
        subject.set_best_for_gender_category_and_event(
          GenderType.find_by_code("M"),
          season.category_types.find_by_code("M25"),
          EventType.find_by_code("50SL"),
          total_events,
          events_swam
        )
        expect(
          subject.get_best_for_gender_category_and_event( GenderType.find_by_code("M"), season.category_types.find_by_code("M25"), EventType.find_by_code("50SL") )
        ).to be_a_kind_of( SeasonalEventBestDAO::SingleEventBestDAO )
      end
    end

    describe "#scan_for_gender_category_and_event" do
      it "returns a collection of SingleEventBestDAO" do
        subject.event_bests.clear
        subject.scan_for_gender_category_and_event
        expect( subject.event_bests.size ).to be > 0
        expect( subject.event_bests ).to all(be_a_kind_of( SeasonalEventBestDAO::SingleEventBestDAO ))
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  context "not a valid instance" do
    it "raises an exception for wrong season parameter" do
      expect{ SeasonalEventBestDAO.new( 'Wrong parameter' ) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end

