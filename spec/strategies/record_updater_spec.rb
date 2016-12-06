require 'rails_helper'
require 'benchmark'


describe RecordUpdater, type: :strategy do
  # Use pre-loaded seeds:
  let( :results )  { MeetingIndividualResult.where( swimmer_id: 23 ) }
  let( :fixture )  { results.at( ((rand * 1000) % results.size).to_i ) }
  let( :fixture2 ) { results.at( ((rand * 1000) % results.size).to_i ) }
  let( :fixture3 ) { results.at( ((rand * 1000) % results.size).to_i ) }

  subject { RecordUpdater.new() }


  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method)",
      [
        :find_existing_record_for,
        :is_better,
        :scan_results_for_season_type_records,
        :scan_results_for_team_records,

        :sql_executable_log,
        :updated_records, :added_records
      ]
    )
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#initialize" do
    it "clears the sql_executable_log" do
      expect( subject.sql_executable_log ).to eq("")
    end
    it "clears the updated_records counter" do
      expect( subject.updated_records ).to eq(0)
    end
    it "clears the added_records counter" do
      expect( subject.added_records ).to eq(0)
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#find_existing_record_for" do
    context "when searching for an existing SEASON_TYPE record," do
      let(:fixture) do
        IndividualRecord.where(is_team_record: false).limit(1000).all.sort{ rand - 0.5 }[0]
      end
      let(:test_subject) do
        subject.find_existing_record_for( fixture, false )
      end

      it "returns an instance of IndividualRecord" do
        expect( test_subject ).to be_an_instance_of( IndividualRecord )
      end
    end

    context "when searching for an existing TEAM record," do
      let(:fixture) do
        IndividualRecord.where(is_team_record: true).limit(1000).all.sort{ rand - 0.5 }[0]
      end
      let(:test_subject) do
        subject.find_existing_record_for( fixture, true )
      end

      it "returns an instance of IndividualRecord" do
        expect( test_subject ).to be_an_instance_of( IndividualRecord )
      end
    end

    context "when searching for a missing SEASON_TYPE record," do
      let(:fixture) do
        fixture_row = IndividualRecord.where(is_team_record: false).limit(1000).all.sort{ rand - 0.5 }[0]
        fixture_row.pool_type_id = PoolType::MT33_ID
        fixture_row
      end
      let(:test_subject) do
        subject.find_existing_record_for( fixture, false )
      end

      it "returns nil" do
        expect( test_subject ).to be nil
      end
    end

    context "when searching for a missing TEAM record," do
      let(:fixture) do
        fixture_row = IndividualRecord.where(is_team_record: true).limit(1000).all.sort{ rand - 0.5 }[0]
        fixture_row.pool_type_id = PoolType::MT33_ID
        fixture_row
      end
      let(:test_subject) do
        subject.find_existing_record_for( fixture, true )
      end

      it "returns nil" do
        expect( test_subject ).to be nil
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#is_better" do
    let(:fixture_result) do
      # [Stevem 20150604] It doesn't matter for the method if its actually a MIR or
      # any other kind of result. So this is quicker than using a MIR and doing a query
      # searching for a better or worse record row.
      IndividualRecord.where(is_team_record: false).limit(1000).all.sort{ rand - 0.5 }[0]
    end
    let(:fixture_better_result) do
      fixture = fixture_result.dup
      fixture.seconds -= 1   # We also don't care if the timing turns out to be negative
      fixture.hundreds = 0
      fixture
    end
    let(:fixture_worse_result) do
      fixture = fixture_result.dup
      fixture.seconds += 1
      fixture
    end

    context "when comparing a non-nil MIR with a nil record row," do
      it "returns true" do
        expect( subject.is_better( fixture_result, nil ) ).to be true
      end
    end

    context "when comparing a MIR with an equal record row," do
      it "returns false" do
        expect( subject.is_better( fixture_result, fixture_result ) ).to be false
      end
    end

    context "when comparing a MIR with a better record row," do
      it "returns false" do
        expect( subject.is_better( fixture_result, fixture_better_result ) ).to be false
      end
    end

    context "when comparing a nil with a non-nil record row," do
      it "returns false" do
        expect( subject.is_better( nil, fixture_result ) ).to be false
      end
    end

    context "when comparing a MIR with a worse record row," do
      it "returns true" do
        expect( subject.is_better( fixture_result, fixture_worse_result ) ).to be true
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#scan_results_for_season_type_records" do
    let(:fixture_result_list) do
      IndividualRecord.where(is_team_record: false).limit(1000).all.sort{ rand - 0.5 }[0..5]
    end
    let(:fixture_better_list) do
      list = IndividualRecord.where(is_team_record: false).limit(1000).all.sort{ rand - 0.5 }[0..5]
      list.map{ |row| row.seconds -= 1; row }
    end


    context "when scanning an empty list (with no new record or record updates)," do
      let(:test_subject) do
        new_subject = RecordUpdater.new()
        new_subject.scan_results_for_season_type_records( [] )
        new_subject
      end

      it "leaves both #updated_records & #added_records counters to zero" do
        expect( test_subject.updated_records ).to eq(0)
        expect( test_subject.added_records ).to eq(0)
      end

      it "updates the SQL executable log text with no INSERT statements" do
        expect( test_subject.sql_executable_log ).not_to match(/INSERT\s/i)
      end
      it "updates the SQL executable log text with no UPDATE statements" do
        expect( test_subject.sql_executable_log ).not_to match(/UPDATE\s/i)
      end
    end


    context "when scanning a list of MIRs with no new record or record updates," do
      let(:test_subject) do
        new_subject = RecordUpdater.new()
        new_subject.scan_results_for_season_type_records( fixture_result_list )
        new_subject
      end

      it "leaves both #updated_records & #added_records counters to zero" do
        expect( test_subject.updated_records ).to eq(0)
        expect( test_subject.added_records ).to eq(0)
      end

      it "updates the SQL executable log text with no INSERT statements" do
        expect( test_subject.sql_executable_log ).not_to match(/INSERT\s/i)
      end
      it "updates the SQL executable log text with no UPDATE statements" do
        expect( test_subject.sql_executable_log ).not_to match(/UPDATE\s/i)
      end
    end


    context "when scanning a list of MIRs with some record updates," do
      let(:test_subject) do
        new_subject = RecordUpdater.new()
        new_subject.scan_results_for_season_type_records( fixture_better_list )
        new_subject
      end

      it "sets the #updated_records counter to the number of updated rows" do
        expect( test_subject.updated_records ).to eq( fixture_better_list.size )
      end
      it "leaves the #added_records counter to zero" do
        expect( test_subject.added_records ).to eq(0)
      end

      it "updates the SQL executable log text with no INSERT statements" do
        expect( test_subject.sql_executable_log ).not_to match(/INSERT\s/i)
      end
      it "updates the SQL executable log text with UPDATE statements" do
        expect( test_subject.sql_executable_log ).to match(/UPDATE\s/i)
# DEBUG
#        puts( "\r\nResulting SQL for updates:\r\n----8<----\r\n" + test_subject.sql_executable_log + "\r\n----8<----\r\n")
      end
    end


    context "when scanning a list of MIRs with some new (missing) records," do
      let(:fixture_missing_list) do
        MeetingIndividualResultFactoryTools.create_unique_result_list( create(:swimmer), 3 )
      end
# XXX THIS WAS FAILING RANDOMLY W/ nil federation_type for some MIR, (see RecordUpdater @ line 163) - corrected with new fixture_missing_list
      let(:test_subject) do
        new_subject = RecordUpdater.new()
        new_subject.scan_results_for_season_type_records( fixture_missing_list )
        new_subject
      end

      it "leaves the #updated_records counter to zero" do
        expect( test_subject.updated_records ).to eq(0)
      end
# FIXME The following is failing randomly:
      it "sets the #added_records counter to the number of inserted rows" do
        expect( test_subject.added_records ).to eq( fixture_missing_list.size )
      end

      it "updates the SQL executable log text with INSERT statements" do
        expect( test_subject.sql_executable_log ).to match(/INSERT\s/i)
# DEBUG
        puts( "\r\nResulting SQL for inserts:\r\n----8<----\r\n" + test_subject.sql_executable_log + "\r\n----8<----\r\n")
      end
# FIXME The following is failing randomly:
      it "updates the SQL executable log text with no UPDATE statements" do
# DEBUG
        puts( "\r\nResulting SQL for UPDATE:\r\n----8<----\r\n" + test_subject.sql_executable_log + "\r\n----8<----\r\n")
        expect( test_subject.sql_executable_log ).not_to match(/UPDATE\s/i)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#scan_results_for_team_records" do
    let(:fixture_result_list) do
      IndividualRecord.where(is_team_record: true).limit(1000).all.sort{ rand - 0.5 }[0..5]
    end
    let(:fixture_better_list) do
      list = IndividualRecord.where(is_team_record: true).limit(1000).all.sort{ rand - 0.5 }[0..5]
      list.map{ |row| row.seconds -= 1; row }
    end


    context "when scanning an empty list (with no new record or record updates)," do
      let(:test_subject) do
        new_subject = RecordUpdater.new()
        new_subject.scan_results_for_team_records( [] )
        new_subject
      end

      it "leaves both #updated_records & #added_records counters to zero" do
        expect( test_subject.updated_records ).to eq(0)
        expect( test_subject.added_records ).to eq(0)
      end

      it "updates the SQL executable log text with no INSERT statements" do
        expect( test_subject.sql_executable_log ).not_to match(/INSERT\s/i)
      end
      it "updates the SQL executable log text with no UPDATE statements" do
        expect( test_subject.sql_executable_log ).not_to match(/UPDATE\s/i)
      end
    end


    context "when scanning a list of MIRs with no new record or record updates," do
      let(:test_subject) do
        new_subject = RecordUpdater.new()
        new_subject.scan_results_for_team_records( fixture_result_list )
        new_subject
      end

      it "leaves both #updated_records & #added_records counters to zero" do
        expect( test_subject.updated_records ).to eq(0)
        expect( test_subject.added_records ).to eq(0)
      end

      it "updates the SQL executable log text with no INSERT statements" do
        expect( test_subject.sql_executable_log ).not_to match(/INSERT\s/i)
      end
      it "updates the SQL executable log text with no UPDATE statements" do
        expect( test_subject.sql_executable_log ).not_to match(/UPDATE\s/i)
      end
    end


    context "when scanning a list of MIRs with some record updates," do
      let(:test_subject) do
        new_subject = RecordUpdater.new()
        new_subject.scan_results_for_team_records( fixture_better_list )
        new_subject
      end

      it "sets the #updated_records counter to the number of updated rows" do
        expect( test_subject.updated_records ).to eq( fixture_better_list.size )
      end
      it "leaves the #added_records counter to zero" do
        expect( test_subject.added_records ).to eq(0)
      end

      it "updates the SQL executable log text with no INSERT statements" do
        expect( test_subject.sql_executable_log ).not_to match(/INSERT\s/i)
      end
      it "updates the SQL executable log text with UPDATE statements" do
        expect( test_subject.sql_executable_log ).to match(/UPDATE\s/i)
# DEBUG
#        puts( "\r\nResulting SQL for updates:\r\n----8<----\r\n" + test_subject.sql_executable_log + "\r\n----8<----\r\n")
      end
    end


    context "when scanning a list of MIRs with some new (missing) records," do
      let(:fixture_missing_list) do
        MeetingIndividualResultFactoryTools.create_unique_result_list( create(:swimmer), 3 )
        # XXX Old method (wrong -- cannot use build, must force a create instead; see above):
        # We use a factory to create a list of MIRs in a meeting on 33mts, so that
        # we may be sure that there won't ever be records for these events:
  #      mir_list = build_list( :meeting_individual_result, 3 )
  #      mir_list.each do |mir|
  #        pool = mir.meeting.swimming_pools.first
  #        pool.pool_type_id = PoolType::MT33_ID
  #      end
  #      mir_list
      end
      let(:test_subject) do
        new_subject = RecordUpdater.new()
        new_subject.scan_results_for_team_records( fixture_missing_list )
        new_subject
      end

      it "leaves the #updated_records counter to zero" do
        expect( test_subject.updated_records ).to eq(0)
      end
      it "sets the #added_records counter to the number of inserted rows" do
        expect( test_subject.added_records ).to eq( fixture_missing_list.size )
      end

      it "updates the SQL executable log text with INSERT statements" do
        expect( test_subject.sql_executable_log ).to match(/INSERT\s/i)
# DEBUG
#        puts( "\r\nResulting SQL for inserts:\r\n----8<----\r\n" + test_subject.sql_executable_log + "\r\n----8<----\r\n")
      end
      it "updates the SQL executable log text with no UPDATE statements" do
        expect( test_subject.sql_executable_log ).not_to match(/UPDATE\s/i)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
