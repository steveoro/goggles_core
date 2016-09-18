require 'rails_helper'
require 'benchmark'


describe RecordCollector, type: :strategy do
  # Use pre-loaded seeds:
  let( :results )  { MeetingIndividualResult.where( swimmer_id: 23 ) }
  let( :fixture )  { results.at( ((rand * 1000) % results.size).to_i ) }
  let( :fixture2 ) { results.at( ((rand * 1000) % results.size).to_i ) }
  let( :fixture3 ) { results.at( ((rand * 1000) % results.size).to_i ) }

  # TODO refactor tests using a 4-element array of subjects, for each subject do the tests

  subject { RecordCollector.new() }
  # TODO Extract all tests on subject as shared examples & test subject with different context pre-filtering as below:
  # TODO test context for prefiltering with a Team => subject { RecordCollector.new(team: Team.find_by_id(1)) }
  # TODO test context for prefiltering with a SeasonType
  # TODO test context for prefiltering with a Swimmer
  # TODO test context for prefiltering with a Season


  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method)",
      [
        :swimmer,
        :team,
        :season,
        :season_type,
        :meeting,
        :collection,
        :count,
        :clear,
        :collect_from_results_having,
        :collect_from_all_category_results_having,
        :collect_from_records_having,
        :get_collected_season_types,
        :save,
        :commit,
        :full_scan,

        :sql_executable_log
      ]
    )
    it_behaves_like( "(the existance of a method returning an Enumerable of non-empty Strings)",
      [
        :record_type_code_list,
        :pool_type_code_list,
        :event_type_codes_list,
        :category_type_codes_list,
        :gender_type_codes_list
      ]
    )
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#initialize" do
    it "allows a list of IndividualRecord rows as a parameter" do
      # The created list must be of unique, distict rows or the add
      # process of the constructor may overwrite items falling into
      # the same category, type & age groups.
      #
      # For this reason, here we cannot use a simple "create_list(:individual_record, 5)".
      list = IndividualRecordFactoryTools.create_personal_best_list( create(:swimmer) )
      # default record_type_code: 'SPB' => "Swimmer Personal-best"-type of record, ID ~> 1
      result = RecordCollector.new( list: list )
      expect( result ).to be_an_instance_of( RecordCollector )
      expect( result.count ).to eq( list.size )
    end
    it "allows a list of MeetingIndividualResult rows as a parameter" do
      # Same previous example above, if we want to test the exact lenght
      # of the internal result list, we cannot rely on a simple "create_list".
      list = MeetingIndividualResultFactoryTools.create_unique_result_list( create(:swimmer) )
      # record_type_code: 'FOR' => Federation-type record, ID ~> 7
      result = RecordCollector.new( list: list, record_type_code: 'FOR' )
      expect( result ).to be_an_instance_of( RecordCollector )
      expect( result.count ).to eq( list.size )
    end
    it "allows a season instance as a parameter" do
      fix_par = create(:season)
      result = RecordCollector.new( season: fix_par )
      expect( result ).to be_an_instance_of( RecordCollector )
      expect( result.season ).to eq( fix_par )
    end
    it "allows a meeting instance as a parameter" do
      fix_par = create(:meeting)
      result = RecordCollector.new( meeting: fix_par )
      expect( result ).to be_an_instance_of( RecordCollector )
      expect( result.meeting ).to eq( fix_par )
    end
    it "allows a team instance as a parameter" do
      fix_par = create(:team)
      result = RecordCollector.new( team: fix_par )
      expect( result ).to be_an_instance_of( RecordCollector )
      expect( result.team ).to eq( fix_par )
    end
    it "allows a swimmer instance as a parameter" do
      fix_par = create(:swimmer)
      result = RecordCollector.new( swimmer: fix_par )
      expect( result ).to be_an_instance_of( RecordCollector )
      expect( result.swimmer ).to eq( fix_par )
    end
    it "allows a season type instance as a parameter" do
      fix_par = create(:season_type)
      result = RecordCollector.new( season_type: fix_par )
      expect( result ).to be_an_instance_of( RecordCollector )
      expect( result.season_type ).to eq( fix_par )
    end
    it "allows a start date instance as a parameter" do
      fix_par = Date.new
      result = RecordCollector.new( start_date: fix_par )
      expect( result ).to be_an_instance_of( RecordCollector )
      expect( result.start_date ).to eq( fix_par )
    end
    it "allows an end date instance as a parameter" do
      fix_par = Date.new
      result = RecordCollector.new( end_date: fix_par )
      expect( result ).to be_an_instance_of( RecordCollector )
      expect( result.end_date ).to eq( fix_par )
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#collection" do
    context "when testing an unfiltered subject," do
      it "returns the collection instance" do
        expect( subject.collection ).to be_an_instance_of( RecordCollection )
      end
      # This is useful if the getter is implemented using #dup or #clone.
      # [Steve, 20140717] *** Currently: NOT ***
      it "returns a collection having the same number of elements of the internal collection" do
        expect( subject.collection.count ).to eq(subject.count)
      end
    end
  end

  describe "#count" do
    context "when testing an unfiltered subject," do
      it "returns the size of the internal collection" do
        subject.clear
        expect( subject.count ).to eq(0)
      end
      it "clears the internal list" do
        subject.collect_from_results_having('25', '100DO', 'M35', 'M', 'FOR')
        expect( subject.count ).to be > 0
      end
    end
  end

  describe "#clear" do
    context "when testing an unfiltered subject," do
      it "returns the cleared collection instance" do
        expect( subject.clear ).to be_an_instance_of( RecordCollection )
      end
      it "clears the internal list" do
        subject.collect_from_results_having('25', '100DO', 'M35', 'M', 'FOR')
        expect{ subject.clear }.to change{ subject.count }.to(0)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#collect_from_results_having" do
    context "when testing an unfiltered subject," do
      it "returns an instance of RecordCollection" do
        expect( subject.collect_from_results_having('25', '100DO', 'M35', 'M', 'FOR') ).to be_an_instance_of( RecordCollection )
      end
      it "returns collection of no more than 2 records" do
        result = subject.collect_from_results_having('50', '100DO', 'M40', 'M', 'FOR')
        expect( result.count ).to be < 3
      end
    end

    context "with a subject filtered by MEETING," do
      let(:meeting)   { Meeting.has_results.sort{ rand - 0.5 }[0] }
      subject         { RecordCollector.new( :meeting => meeting ) }

      # TODO
    end

    context "with a subject filtered by TEAM," do
      let(:team)      { Team.has_results.sort{ rand - 0.5 }[0] }
      subject         { RecordCollector.new( :team => team ) }

      # TODO
      it "returns only TEAM records (not federation records)"
    end
  end

  describe "#collect_from_records_having" do
    context "when testing an unfiltered subject," do
      it "returns an instance of RecordCollection" do
        expect( subject.collect_from_records_having('25', '100DO', 'M35', 'M', 'FOR') ).to be_an_instance_of( RecordCollection )
      end
      it "returns collection of no more than 2 records" do
        result = subject.collect_from_records_having('50', '100DO', 'M40', 'M', 'FOR')
        expect( result.count ).to be < 3
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#get_collected_season_types" do
    context "when testing an unfiltered subject," do
      it "returns an instance of Hash" do
        expect( subject.get_collected_season_types ).to be_an_instance_of( Hash )
      end
      it "returns at least a number lesser or equal to the total collection count" do
        expect( subject.get_collected_season_types.count ).to be <= subject.count
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#save" do
    before(:each) do
      subject.collect_from_records_having('25', '100DO', 'M35', 'M', 'FOR')
      expect( subject.count ).to be > 0
    end

    context "when saving existing records," do
      it "returns true on no-errors found" do
        expect( subject.save ).to be true
      end
      it "does not clear the internal list" do
        expect{ subject.save }.not_to change{ subject.count }
      end
      it "doesn't increase the table size" do
        expect( subject.save ).to be true  # make the record persist, without clearing the list
        expect{ subject.save }.not_to change{ IndividualRecord.count }
      end
    end
  end


  describe "#commit" do
    before(:each) do
      subject.collect_from_records_having('25', '100DO', 'M35', 'M', 'FOR')
      expect( subject.count ).to be > 0
    end

    context "when saving existing records," do
      it "returns true on no-errors found" do
        expect( subject.commit ).to be true
      end
      it "clears the internal list" do
        expect{ subject.commit }.to change{ subject.count }.to(0)
      end
      it "doesn't alter the table size" do
        before_count = subject.count
        subject.save  # make sure the record persist, without clearing the list
        expect{ subject.commit }.not_to change{ IndividualRecord.count }
      end
      it "doesn't alter the table size" do
        before_count = subject.count
        expect{ subject.commit }.not_to change{ IndividualRecord.count }
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#full_scan" do
    it "returns an instance of RecordCollection" do
      # Do nothing, just test the result
      expect( subject.full_scan() ).to be_an_instance_of( RecordCollection )
    end

    # Disabled to speed-up the testing process:
#    it "benchmarks the scan duration" do
#      puts "\r\n\t*** Benchmark for #full_scan() ***"
#      Benchmark.bmbm do |x|
#        x.report("records")  {
#          subject.full_scan() do |this, pool_code, event_code, category_code, gender_code|
#            this.collect_from_records_having( pool_code, event_code, category_code, gender_code, 'FOR' )
#          end
#        }
#        # Worthless comparison:
#        x.report("no block") { subject.full_scan() }
#      end
#      puts ''
#    end
  end
  #-- -------------------------------------------------------------------------
  #++


  context "when filtering with a :meeting," do
    let(:meeting)   { Meeting.has_results.sort{ rand - 0.5 }[0] }
    subject         { RecordCollector.new( :meeting => meeting ) }

    describe "#meeting" do
      it "returns the meeting specified in the constructor" do
        expect( subject.meeting.id ).to eq( meeting.id )
      end
    end

    describe "#pool_type_code_list" do
      it "returns the pool_type codes of the sessions from the meeting used as filter" do
        expect(
          subject.pool_type_code_list
        ).to match_array( meeting.pool_types.to_a.flatten.map{ |row| row.code }.flatten.uniq )
      end
    end

    describe "#event_type_codes_list" do
      it "returns the event_type codes of the sessions from the meeting used as filter" do
        expect(
          subject.event_type_codes_list
        ).to match_array(
          meeting.event_types.are_not_relays.to_a.flatten.map{ |row| row.code }.flatten.uniq
        )
      end
    end

    describe "#category_type_codes_list" do
      it "returns the category_type codes of the sessions from the meeting used as filter" do
        expect(
          subject.category_type_codes_list
        ).to match_array(
          meeting.meeting_events.to_a.flatten.uniq.map{ |me|
            me.category_types.to_a.flatten.map{ |row| row.code }.uniq
          }.flatten.uniq
        )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#seek_existing_record_for" do
    context "when searching for an existing FEDERATION record," do
      let(:existing_ind_record) { IndividualRecord.where(is_team_record: false).limit(1000).all.sort{ rand - 0.5 }[0] }
      let(:test_subject) do
        subject.seek_existing_record_for( existing_ind_record, false )
      end

      it "returns an instance of IndividualRecord" do
        expect( test_subject ).to be_an_instance_of( IndividualRecord )
      end
    end

    context "when searching for an existing TEAM record," do
      let(:existing_ind_record) { IndividualRecord.where(is_team_record: true).limit(1000).all.sort{ rand - 0.5 }[0] }
      let(:test_subject) do
        subject.seek_existing_record_for( existing_ind_record, true )
      end

      it "returns an instance of IndividualRecord" do
        expect( test_subject ).to be_an_instance_of( IndividualRecord )
      end
    end

    context "when searching for a missing FEDERATION record," do
      let(:missing_ind_record) do
        fixture_row = IndividualRecord.where(is_team_record: false).limit(1000).all.sort{ rand - 0.5 }[0]
        fixture_row.pool_type_id = PoolType::MT33_ID
        fixture_row
      end
      let(:test_subject) do
        subject.seek_existing_record_for( missing_ind_record, false )
      end

      it "returns nil" do
        expect( test_subject ).to be nil
      end
    end

    context "when searching for a missing TEAM record," do
      let(:missing_ind_record) do
        fixture_row = IndividualRecord.where(is_team_record: true).limit(1000).all.sort{ rand - 0.5 }[0]
        fixture_row.pool_type_id = PoolType::MT33_ID
        fixture_row
      end
      let(:test_subject) do
        subject.seek_existing_record_for( missing_ind_record, true )
      end

      it "returns nil" do
        expect( test_subject ).to be nil
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
