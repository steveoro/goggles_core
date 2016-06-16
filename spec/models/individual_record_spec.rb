require 'spec_helper'
require 'date'

describe IndividualRecord, :type => :model do

  context "[a well formed instance]" do
    subject { create( :individual_record ) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [ 
      :pool_type,
      :event_type,
      :gender_type,
      :team,
      :season,
      :season_type,
      :federation_type,
      :meeting_individual_result,
      :record_type
    ])    

    # Filtering scopes:
    it_behaves_like( "(the existance of a class method)", [
      :team_records,
      :seasonal_records,
      :for_team,
      :for_season_type,
      :for_federation,
      :for_federation_code
    ])

    context "[implemented methods]" do
      it_behaves_like( "(the existance of a method)",
        [
          :from_individual_result
        ]
      )
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "self.for_team" do
      it "returns an instance of ActiveRecord::Relation" do
        expect( subject.class.for_team(1) ).to be_an_instance_of( ActiveRecord::Relation )
      end
    end

    describe "self.for_season_type" do
      it "returns an instance of ActiveRecord::Relation" do
        # season_type_id: 2 => 'MASCSI'
        expect( subject.class.for_season_type(2) ).to be_an_instance_of( ActiveRecord::Relation )
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#from_individual_result" do
      it "accepts a MeetingIndividualResult and RecordType parameters" do
        fix_record_type = RecordType.find( ((rand * 7) % 7).to_i + 1 )
        fixture = create( :meeting_individual_result )
        expect(
          subject.from_individual_result( fixture, fix_record_type )
        ).to be_an_instance_of( IndividualRecord )
      end
      it "raises an exception for a nil parameter" do
        expect{ subject.from_individual_result( nil ) }.to raise_error( ArgumentError )
      end
      it "raises an exception for an unsupported parameter" do
        expect{ subject.from_individual_result( '' ) }.to raise_error( ArgumentError )
      end
      it "raises an exception for missing record type parameter" do
        fixture = create( :meeting_individual_result )
        expect{ subject.from_individual_result( fixture ) }.to raise_error( ArgumentError )
      end
      it "copies the member values into the instance" do
        fix_record_type = RecordType.find( ((rand * 7) % 7).to_i + 1 )
        fixture = create( :meeting_individual_result )
        result = IndividualRecord.new.from_individual_result( fixture, fix_record_type )
        expect( result.pool_type_id ).to eq( fixture.pool_type.id )
        expect( result.event_type_id ).to eq( fixture.event_type.id )
        expect( result.category_type_id ).to eq( fixture.category_type.id )
        expect( result.gender_type_id ).to eq( fixture.gender_type.id )
        expect( result.minutes ).to eq( fixture.minutes )
        expect( result.seconds ).to eq( fixture.seconds )
        expect( result.hundreds ).to eq( fixture.hundreds )
        expect( result.swimmer_id ).to eq( fixture.swimmer.id )
        expect( result.team_id ).to eq( fixture.team.id )
        expect( result.season_id ).to eq( fixture.season.id )
        expect( result.federation_type_id ).to eq( fixture.season.federation_type.id )
        expect( result.record_type_id ).to eq( fix_record_type.id )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
