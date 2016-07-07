require 'rails_helper'


describe PersonalBestGridBuilder, type: :strategy do
  let( :swimmer )  { Swimmer.find( 23 ) }  # Assumes swimmer Leega from seeds
  let( :events_by_pool_type ) { EventsByPoolType.find( 11 )}  # Assumes 50FA, 25 mt from seeds
  let( :individual_record_list ) { create_list(:individual_record, 5, {swimmer_id: swimmer.id}) }
  let( :pool_type ) { PoolType.only_for_meetings.first }
  let( :record_type ) { RecordType.for_swimmers.first }

  # Using a pre-filled collector will speed-up the tests:
  subject { PersonalBestGridBuilder.new( PersonalBestCollector.new( swimmer, list: individual_record_list, record_type: record_type ) ) }

  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method)",
      [
        :collection,
        :count,
        :event_types
      ]
    )
    it_behaves_like( "(the existance of a method returning a collection of some kind of instances)",
      [
        :pool_types,
        :record_types
      ],
      ActiveRecord::Base
    )
    # Leega
    # :event_types tested a part because has a parameter
  end


  describe "#initialize" do
    it "allows an instance of PersonalBestCollector as a parameter" do
      expect( subject ).to be_an_instance_of( PersonalBestGridBuilder )
      expect( subject.count ).to be > 0
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

  describe "#count" do
    it "clears the internal list" do
      subject.clear
      expect( subject.count ).to eq(0)
    end
    it "returns the size of the internal collection" do
      expect( subject.collection.count ).to eq(subject.count)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#event_types" do
    it "returns a collection responding to :each" do
      expect( subject.event_types( pool_type.id ) ).to respond_to(:each)
    end
    it "returns a collection responding to :count" do
      expect( subject.event_types( pool_type.id ) ).to respond_to(:count)
    end
    it "returns a list of ActiveRecord::Base" do
      subject.event_types( pool_type.id ).each do |element|
        expect( element ).to be_a_kind_of( ActiveRecord::Base )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
