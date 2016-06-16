require 'spec_helper'


describe RecordX4dDAO, type: :model do

  #let(:pool)            { PoolType.only_for_meetings[(rand * (PoolType.only_for_meetings.count - 1)).round(0)].code }
  #let(:gender)          { GenderType.individual_only[(rand * (GenderType.individual_only.count - 1)).round(0)].code }
  #let(:event)           { EventType.are_not_relays.for_fin_calculation[(rand * (EventType.are_not_relays.for_fin_calculation.count - 1)).round(0)].code }
  #let(:category)        { CategoryType.are_not_relays[(rand * (CategoryType.are_not_relays.count - 1)).round(0)].code }
  #let(:record_type)     { RecordType.all[(rand * (RecordType.all.count - 1)).round(0)] }

  let(:gender)          { GenderType.individual_only.order('RAND()').first.code }
  let(:pool)            { PoolType.only_for_meetings.order('RAND()').first.code }
  let(:event)           { EventType.are_not_relays.for_fin_calculation.order('RAND()').first.code }
  let(:category)        { CategoryType.are_not_relays.order('RAND()').first.code }
  let(:record_type)     { RecordType.order('RAND()').first }

  let(:mir)             { create( :meeting_individual_result ) }

  context "RecordElementDAO subclass," do

    describe "[a well formed instance]" do
      subject { RecordX4dDAO::RecordElementDAO.new( pool, gender, event, category, mir ) }

      it_behaves_like( "(the existance of a method)", [
        :get_pool_type,
        :get_gender_type,
        :get_event_type,
        :get_category_type,
        :get_record_instance
      ] )

      it_behaves_like( "(the existance of a method returning strings)", [
        :get_record_timing,
        :get_record_date
      ] )

      describe "#parameters," do
        it "are the given parameters" do
          expect( subject.pool_type_code ).to eq( pool )
          expect( subject.gender_type_code ).to eq( gender )
          expect( subject.event_type_code ).to eq( event )
          expect( subject.category_type_code ).to eq( category )
          expect( subject.record ).to eq( mir )
       end
      end

      describe "#get_pool_type," do
        it "returns a string" do
          expect( subject.get_pool_type ).to be_an_instance_of( String )
        end
        it "returns the pool parameter set" do
          expect( subject.get_pool_type ).to eq( pool )
        end
      end

      describe "#get_gender_type," do
        it "returns a string" do
          expect( subject.get_gender_type ).to be_an_instance_of( String )
        end
        it "returns the pool parameter set" do
          expect( subject.get_gender_type ).to eq( gender )
        end
      end

      describe "#get_event_type," do
        it "returns a string" do
          expect( subject.get_event_type ).to be_an_instance_of( String )
        end
        it "returns the pool parameter set" do
          expect( subject.get_event_type ).to eq( event )
        end
      end

      describe "#get_category_type," do
        it "returns a string" do
          expect( subject.get_category_type ).to be_an_instance_of( String )
        end
        it "returns the pool parameter set" do
          expect( subject.get_category_type ).to eq( category )
        end
      end

      describe "#get_record_instance," do
        it "returns a meeting individual result" do
          expect( subject.get_record_instance ).to be_an_instance_of( MeetingIndividualResult )
        end
        it "returns the pool parameter set" do
          expect( subject.get_record_instance ).to eq( mir )
        end
      end

      describe "#get_record_timing," do
        it "retrurns the record timing" do
          expect( subject.get_record_timing ).to eq( mir.get_timing )
        end
      end

      describe "#get_record_date," do
        it "retrurns the meeting scheduled daterecord timing" do
          expect( subject.get_record_date ).to eq( mir.meeting.get_scheduled_date )
        end
      end

# FIXME [Steve] NO DECORATOR CALLS in CORE 5.0
#      describe "#get_record_swimmer," do
#        it "responds to #get_record_swimmer" do
#          expect( subject ).to respond_to( :get_record_swimmer )
#        end
#        it "returns an HTML link" do
#          expect( subject.get_record_swimmer ).to include( mir.swimmer.get_full_name )
#        end
#      end

# FIXME [Steve] NO DECORATOR CALLS in CORE 5.0
#      describe "#get_record_meeting," do
#        it "responds to #get_record_swimmer" do
#          expect( subject ).to respond_to( :get_record_meeting )
#        end
#        it "returns an HTML link" do
#          expect( subject.get_record_meeting ).to include( mir.meeting.get_short_name )
#        end
#      end
    end
    #-- -------------------------------------------------------------------------

    describe "without requested parameters" do
      it "raises an exception for wrong record parameter" do
        expect{ RecordX4dDAO::RecordElementDAO.new( pool, gender, event, category, 'WRONG_RECORD' ) }.to raise_error( ArgumentError )
        expect{ RecordX4dDAO::RecordElementDAO.new( pool, gender, event, category ) }.to raise_error( ArgumentError )
      end
    end
    #-- -------------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++

  subject { RecordX4dDAO.new( "Something", record_type ) }

  describe "[a well formed instance]" do

    it_behaves_like( "(existance of a member array)", [
      :records
    ])

    it_behaves_like( "(the existance of a method)", [
      :add_record,
      :record_count,
      :has_record_for?,
      :get_record_instance,
      :get_record,
      :delete_record
    ] )

    describe "#parameters," do
      it "are the given parameters" do
        expect( subject.owner ).to eq( "Something" )
        expect( subject.record_type ).to eq( record_type )
     end
    end
    #-- -------------------------------------------------------------------------

  end
  #-- -------------------------------------------------------------------------
  #++

  describe "without requested parameters," do
    it "raises an exception for missing parameter" do
      expect{ RecordX4dDAO.new() }.to raise_error( ArgumentError )
      expect{ RecordX4dDAO.new( "Something" ) }.to raise_error( ArgumentError )
    end
    it "raises an exception for wrong record parameter" do
      expect{ RecordX4dDAO.new( "Something", "Wrong record type" ) }.to raise_error( ArgumentError )
    end
  end

  describe "#add_record," do
    it "returns a boolean" do
      expect( subject.add_record( mir ) ).to eq( true ).or eq( false )
    end
    it "adds an element to records collection" do
      record_num = subject.records.size
      expect( subject.add_record( mir ) ).to eq( true )
      expect( subject.records.size ).to be > record_num
    end
    it "adds an element to records collection if optional parameters given" do
      record_num = subject.records.size
      expect( subject.add_record( mir, category, pool, gender, event ) ).to eq( true )
      expect( subject.records.size ).to be > record_num
    end
    it "doesn't add an element to records collection if wrong parameters" do
      record_num = subject.records.size
      expect( subject.add_record( "wrong_par" ) ).to eq( false )
      expect( subject.records.size ).to eq( record_num )
    end
    it "replace an element to records collection if already present" do
      record_num = subject.records.size
      expect( subject.add_record( mir, category, pool, gender, event ) ).to eq( true )
      expect( subject.add_record( mir, category, pool, gender, event ) ).to eq( true )
      expect( subject.add_record( create( :meeting_individual_result ), category, pool, gender, event ) ).to eq( true )
      expect( subject.records.size ).to be > record_num
    end
    it "adds an element of RecordElement type" do
      expect( subject.records.size ).to eq( 0 )
      subject.add_record( mir )
      expect( subject.records.size ).to eq( 1 )
      expect( subject.records[0] ).to be_an_instance_of( RecordX4dDAO::RecordElementDAO )
    end
    it "uses record pool, gender, event and category if not forced" do
      subject.add_record( mir )
      expect( subject.records[0].get_pool_type ).to eq( mir.pool_type.code )
      expect( subject.records[0].get_gender_type ).to eq( mir.gender_type.code )
      expect( subject.records[0].get_event_type ).to eq( mir.event_type.code )
      expect( subject.records[0].get_category_type ).to eq( mir.category_type.code )
    end
    it "uses forced pool, gender, event and category instead of record ones if forced" do
      subject.add_record( mir, category, pool, gender, event )
      expect( subject.records[0].get_pool_type ).to eq( pool )
      expect( subject.records[0].get_gender_type ).to eq( gender )
      expect( subject.records[0].get_event_type ).to eq( event )
      expect( subject.records[0].get_category_type ).to eq( category )
    end
  end

  describe "#record_count," do
    it "returns a number" do
      expect( subject.record_count ).to be >= 0
    end
    it "returns 0 for empty record collection" do
      expect( subject.records.size ).to eq( 0 )
      expect( subject.record_count ).to eq( 0 )
    end
    it "returns the number of records colelction" do
      num_record = ( rand * 10 ).to_i + 5
      (0..num_record).each_with_index do |index|
        subject.add_record( mir, index.to_s )
      end
      expect( subject.records.size ).to be > 0
      expect( subject.record_count ).to eq( subject.records.size )
    end
  end

  describe "#has_record_for?," do
    it "returns nil if no records present" do
      expect( subject.records.size ).to eq( 0 )
      expect( subject.has_record_for?( pool, gender, event, category ) ).to be nil
      expect( subject.has_record_for?( pool, gender, nil, category ) ).to be nil
      expect( subject.has_record_for?( pool, gender, event, nil ) ).to be nil
      expect( subject.has_record_for?( pool, gender, nil, nil ) ).to be nil
    end
    it "returns nil if no record present for given parameters" do
      subject.add_record( mir )
      expect( subject.records.size ).to be > 0
      expect( subject.has_record_for?( 'not_possible_pool', 'impossible_gender', 'unknown_event', 'non_existent_category' ) ).to be nil
    end
    it "returns a number if record present for given parameters" do
      subject.add_record( mir, category, pool, gender, event )
      expect( subject.has_record_for?( pool, gender, event, category ) ).to be >= 0
      expect( subject.has_record_for?( pool, gender, nil, category ) ).to be >= 0
      expect( subject.has_record_for?( pool, gender, event, nil ) ).to be >= 0
      expect( subject.has_record_for?( pool, gender, nil, nil ) ).to be >= 0
    end
    it "returns the correct number if record present for given parameters" do
      subject.add_record( mir, category, pool, gender, event )
      subject.add_record( mir, 'another_category', pool, gender, event )
      subject.add_record( mir, category, 'another_pool', gender, event )
      subject.add_record( mir, category, pool, 'another_gender', event )
      subject.add_record( mir, category, pool, gender, 'another_event' )
      expect( subject.has_record_for?( pool, gender, event, category ) ).to eq( 0 )
    end
  end

  describe "#get_record_instance," do
    it "returns nil if no records set" do
      expect( subject.records.size ).to eq( 0 )
      expect( subject.get_record_instance( pool, gender, event, category ) ).to be nil
    end
    it "returns nil if no record set for given parameters" do
      subject.add_record( mir, 'non_existent_category', 'not_possible_pool', 'impossible_gender', 'unknown_event' )
      subject.add_record( mir, 'another_category' )
      subject.add_record( mir, 'the_last_category' )
      subject.add_record( mir, mir.category_type.code, 'different_pool' )
      subject.add_record( mir, mir.category_type.code, mir.pool_type.code, 'different_gender' )
      subject.add_record( mir, mir.category_type.code, mir.pool_type.code, mir.gender_type.code, 'different_event' )
      expect( subject.records.size ).to be > 0
      expect( subject.get_record_instance( pool, gender, event, category ) ).to be nil
    end
    it "returns a meeting individual record if record present" do
      subject.add_record( mir, category, pool, gender, event )
      expect( subject.get_record_instance( pool, gender, event, category ) ).to be_an_instance_of( MeetingIndividualResult )
    end
  end

  describe "#get_record," do
    it "returns nil if no records set" do
      expect( subject.records.size ).to eq( 0 )
      expect( subject.get_record( pool, gender, event, category ) ).to be nil
      expect( subject.get_record( pool, gender, event, category, :get_record_timing ) ).to be nil
      expect( subject.get_record( pool, gender, event, category, :get_record_date ) ).to be nil
      expect( subject.get_record( pool, gender, event, category, :get_record_swimmer ) ).to be nil
      expect( subject.get_record( pool, gender, event, category, :get_record_meeting ) ).to be nil
    end
    it "returns nil if no record set for given parameters" do
      subject.add_record( mir, 'non_existent_category', 'not_possible_pool', 'impossible_gender', 'unknown_event' )
      subject.add_record( mir, 'another_category' )
      subject.add_record( mir, 'the_last_category' )
      subject.add_record( mir, mir.category_type.code, 'different_pool' )
      subject.add_record( mir, mir.category_type.code, mir.pool_type.code, 'different_gender' )
      subject.add_record( mir, mir.category_type.code, mir.pool_type.code, mir.gender_type.code, 'different_event' )
      expect( subject.records.size ).to be > 0
      expect( subject.get_record( pool, gender, event, category ) ).to be nil
      expect( subject.get_record( pool, gender, event, category, :get_record_timing ) ).to be nil
      expect( subject.get_record( pool, gender, event, category, :get_record_date ) ).to be nil
      expect( subject.get_record( pool, gender, event, category, :get_record_swimmer ) ).to be nil
      expect( subject.get_record( pool, gender, event, category, :get_record_meeting ) ).to be nil
    end
    it "returns a meeting individual record if record present and attribute not set" do
      subject.add_record( mir, category, pool, gender, event )
      expect( subject.get_record( pool, gender, event, category ) ).to be_an_instance_of( MeetingIndividualResult )
    end
    it "returns the record element timing if timing is requested" do
      subject.add_record( mir, category, pool, gender, event )
      expect( subject.get_record( pool, gender, event, category, :get_record_timing ) ).to eq( subject.records[0].get_record_timing )
    end
    it "returns the record element date if date is requested" do
      subject.add_record( mir, category, pool, gender, event )
      expect( subject.get_record( pool, gender, event, category, :get_record_date ) ).to eq( subject.records[0].get_record_date )
    end
# FIXME [Steve] NO DECORATOR CALLS in CORE 5.0
#    it "returns the record element swimmer if swimmer is requested" do
#      subject.add_record( mir, category, pool, gender, event )
#      expect( subject.get_record( pool, gender, event, category, :get_record_swimmer ) ).to eq( subject.records[0].get_record_swimmer )
#    end
# FIXME [Steve] NO DECORATOR CALLS in CORE 5.0
#    it "returns the record element meeting if meeting is requested" do
#      subject.add_record( mir, category, pool, gender, event )
#      expect( subject.get_record( pool, gender, event, category, :get_record_meeting ) ).to eq( subject.records[0].get_record_meeting )
#    end
  end

  describe "#delete_record," do
    it "returns a boolean" do
      expect( subject.delete_record( pool, gender, event, category ) ).to eq( true ).or eq( false )
    end
    it "returns false if no record to delete" do
      expect( subject.has_record_for?( pool, gender, event, category ) ).to be nil
      expect( subject.delete_record( pool, gender, event, category ) ).to eq( false )
      expect( subject.add_record( mir, 'impossible_to_match' ) ).to eq( true )
      expect( subject.has_record_for?( pool, gender, event, category ) ).to be nil
      expect( subject.delete_record( pool, gender, event, category ) ).to eq( false )
    end
    it "returns true if exists a record to delete" do
      subject.add_record( mir, category, pool, gender, event )
      expect( subject.has_record_for?( pool, gender, event, category ) ).to be >= 0
      expect( subject.delete_record( pool, gender, event, category ) ).to eq( true )
    end
    it "deletes the record if exists" do
      subject.add_record( mir, category, pool, gender, event )
      subject.add_record( mir, 'non_existent_category', 'not_possible_pool', 'impossible_gender', 'unknown_event' )
      subject.add_record( mir, 'another_category' )
      subject.add_record( mir, 'the_last_category' )
      subject.add_record( mir, mir.category_type.code, 'different_pool' )
      subject.add_record( mir, mir.category_type.code, mir.pool_type.code, 'different_gender' )
      subject.add_record( mir, mir.category_type.code, mir.pool_type.code, mir.gender_type.code, 'different_event' )
      expect( subject.has_record_for?( pool, gender, event, category ) ).to be >= 0
      element_num = subject.records.size
      expect( subject.delete_record( pool, gender, event, category ) ).to eq( true )
      expect( subject.has_record_for?( pool, gender, event, category ) ).to be nil
      expect( subject.records.size ).to eq( element_num - 1 )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
