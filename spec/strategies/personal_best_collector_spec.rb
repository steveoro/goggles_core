require 'rails_helper'
require 'benchmark'
require 'date'


describe PersonalBestCollector, type: :strategy do
  # Use pre-loaded seeds:
  let( :swimmer )  { Swimmer.find( 23 ) }  # Assumes swimmer Leega from seeds
  let( :events_by_pool_type ) { EventsByPoolType.find( 11 )}  # Assumes 50FA, 25 mt from seeds
  let( :record_type_code )  { RecordType.find( 1 ).code }  # Assumes Swimmer personal best from seeds

  # TODO refactor tests using a 4-element array of subjects, for each subject do the tests
  # TODO test context for prefiltering with a SeasonType
  # TODO test context for prefiltering with a Season

  # Using a given swimmer
  subject { PersonalBestCollector.new( swimmer ) }


  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method)",
      [
        :season,
        :season_type,
        :collection,
        :count,
        :clear,
        :collect_from_all_category_results_having,
        :collect_last_results_having,
        :full_scan,
        :start_date,
        :end_date,
        :events_by_pool_type_list,
        :set_start_date,
        :set_end_date
      ]
    )
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#initialize" do
    it "doesn't allows initialization without swimmer" do
      expect{ PersonalBestCollector.new() }.to raise_error( ArgumentError )
    end
    it "allows a list of IndividualRecord rows as a parameter" do
      list = IndividualRecordFactoryTools.create_personal_best_list( swimmer )
      result = PersonalBestCollector.new( swimmer, list: list )
      expect( result ).to be_an_instance_of( PersonalBestCollector )
      expect( result.count ).to eq( list.size )
    end
    it "allows a list of MeetingIndividualResult rows and a record type as parameters" do
      list = create_list(:meeting_individual_result, 3, swimmer_id: swimmer.id)
      result = PersonalBestCollector.new( swimmer, list: list, record_type_code: record_type_code )
      expect( result ).to be_an_instance_of( PersonalBestCollector )
      expect( result.count ).to be > 0
    end
    it "doesn't allows a list of MeetingIndividualResult rows as a parameter without record type" do
      list = create_list(:meeting_individual_result, 3, swimmer_id: swimmer.id)
      expect{ PersonalBestCollector.new( swimmer, list: list) }.to raise_error( ArgumentError )
    end
    it "allows a season instance as a parameter" do
      fix_par = create(:season)
      result = PersonalBestCollector.new( swimmer, season: fix_par )
      expect( result ).to be_an_instance_of( PersonalBestCollector )
      expect( result.season ).to eq( fix_par )
    end
    it "allows a season type instance as a parameter" do
      fix_par = create(:season_type)
      result = PersonalBestCollector.new( swimmer, season_type: fix_par )
      expect( result ).to be_an_instance_of( PersonalBestCollector )
      expect( result.season_type ).to eq( fix_par )
    end
    it "allows a start date instance as a parameter" do
      fix_par = Date.new
      result = PersonalBestCollector.new( swimmer, start_date: fix_par )
      expect( result ).to be_an_instance_of( PersonalBestCollector )
      expect( result.start_date ).to eq( fix_par )
    end
    it "allows an end date instance as a parameter" do
      fix_par = Date.new
      result = PersonalBestCollector.new( swimmer, end_date: fix_par )
      expect( result ).to be_an_instance_of( PersonalBestCollector )
      expect( result.end_date ).to eq( fix_par )
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#collection" do
    it "returns the collection instance" do
      expect( subject.collection ).to be_an_instance_of( PersonalBestCollection )
    end
    # This is useful if the getter is implemented using #dup or #clone.
    # [Steve, 20140717] *** Currently: NOT ***
    it "returns a collection having the same number of elements of the internal collection" do
      expect( subject.collection.count ).to eq(subject.count)
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#collect_from_all_category_results_having" do
    it "returns the size of the internal collection" do
      subject.collect_from_all_category_results_having( events_by_pool_type, record_type_code )
      expect( subject.count ).to be > 0
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#collect_last_results_having" do
    it "returns the size of the internal collection" do
      subject.collect_last_results_having( events_by_pool_type, record_type_code )
      expect( subject.count ).to be == 1
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#clear" do
    it "returns the cleared collection instance" do
      expect( subject.clear ).to be_an_instance_of( PersonalBestCollection )
    end
    it "clears the internal list" do
      subject.collect_from_all_category_results_having( events_by_pool_type, record_type_code )
      expect{ subject.clear }.to change{ subject.count }.to(0)
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#events_by_pool_type_list" do
    it "returns a non empty collection" do
      expect( subject.events_by_pool_type_list.count ).to be > 0
    end
    it "returns a collection" do
      expect( subject.events_by_pool_type_list ).to be_a_kind_of( ActiveRecord::Relation )
    end
    it "returns a collection of EventsByPoolType" do
      subject.events_by_pool_type_list.each do |element|
        expect( element ).to be_an_instance_of( EventsByPoolType )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#start_date" do
    it "returns a date or a nil value" do
      expect( subject.start_date ).to be_an_instance_of( Date ).or be_nil
    end
    it "retunrs nil if start date nt set" do
      expect( subject.start_date ).to be_nil
    end
    it "returns the start_date internal variable if set" do
      fix_date = Date.today
      fix_pb_collector = PersonalBestCollector.new( swimmer, start_date: fix_date, end_date: fix_date )
      expect( fix_pb_collector.start_date ).to equal( fix_date )
    end
  end

  describe "#set_start_date" do
    it "assigns a given date to start_date internal variable" do
      fix_date = Date.today
      expect( subject.start_date ).to be_nil
      subject.set_start_date( fix_date )
      expect( subject.start_date ).to equal( fix_date )
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#end_date" do
    it "returns a date or a nil value" do
      expect( subject.end_date ).to be_an_instance_of( Date ).or be_nil
    end
    it "retunrs nil if end date nt set" do
      expect( subject.end_date ).to be_nil
    end
    it "returns the end_date internal variable if set" do
      fix_date = Date.today
      fix_pb_collector = PersonalBestCollector.new( swimmer, start_date: fix_date, end_date: fix_date )
      expect( fix_pb_collector.end_date ).to equal( fix_date )
    end
  end

  describe "#set_end_date" do
    it "assigns a given date to end_date internal variable" do
      fix_date = Date.today
      expect( subject.end_date ).to be_nil
      subject.set_end_date( fix_date )
      expect( subject.end_date ).to equal( fix_date )
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#full_scan" do
    it "returns an instance of RecordCollection" do
      # Do nothing, just test the result
      expect( subject.full_scan() ).to be_an_instance_of( PersonalBestCollection )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
