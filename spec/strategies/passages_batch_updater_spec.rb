# encoding: utf-8
require 'spec_helper'
require 'passages_batch_updater'


describe PassagesBatchUpdater, type: :strategy do
  # [Steve] We don't need to save the random user instance created, since we
  # won't use any of its associations, nor its ID, so "build" is enough.
  subject { PassagesBatchUpdater.new( FactoryGirl.build(:user) ) }

  it_behaves_like( "(the existance of a method)", [
    :edited_passages, :new_passages, :destroyed_passages,
    :total_errors,
    :sql_diff_text_log,
    :edit_existing_passage,
    :create_new_passage,
    :is_delta?
  ] )
  #-- -------------------------------------------------------------------------
  #++

  let(:minutes)       { (rand * 59).to_i }
  let(:seconds)       { (rand * 59).to_i }
  let(:hundreds)      { (rand * 59).to_i }
  let(:fixture_value) { "#{ minutes }\'#{ seconds }\"#{ hundreds }" }
  let(:passage)       { create( :meeting_individual_result_with_passages ).passages.sort_by_distance.first }

  let(:long_event)    { EventType.are_not_relays.for_fin_calculation.where('length_in_meters >= 200')[ rand * (EventType.are_not_relays.for_fin_calculation.where('length_in_meters >= 200').count - 1) ] }
  let(:mir_with_pass) { Passage.for_event_type( long_event )[ rand * (Passage.for_event_type( long_event ).count - 1)].meeting_individual_result }
  let(:first_passage) { mir_with_pass.passages.sort_by_distance.first }
  let(:last_passage)  { mir_with_pass.passages.sort_by_distance.last }
  #-- -------------------------------------------------------------------------
  #++

  describe "#edit_existing_passage" do
    context "when editing an existing row with valid parameters," do
      it "updates the row successfully" do
        expect(
          subject.edit_existing_passage( passage.id, fixture_value )
        ).to be true
      end
      it "updates the existing row with the correct source timings parameters" do
        subject.edit_existing_passage( passage.id, fixture_value )
        result_row = Passage.find( passage.id )
        expect( result_row.meeting_individual_result_id ).to eq( passage.meeting_individual_result_id )
        expect( result_row.passage_type_id ).to eq( passage.passage_type_id )
        expect( result_row.team_id ).to eq( passage.team_id )
        expect( result_row.swimmer_id ).to eq( passage.swimmer_id )
        expect( result_row.minutes_from_start ).to eq( minutes )
        expect( result_row.seconds_from_start ).to eq( seconds )
        expect( result_row.hundreds_from_start ).to eq( hundreds )
      end
      it "changes the resulting SQL diff log" do
        expect{
          subject.edit_existing_passage( passage.id, fixture_value )
        }.to change{ subject.sql_diff_text_log }
      end
      it "increases the number of edited rows" do
        expect{
          subject.edit_existing_passage( passage.id, fixture_value )
        }.to change{ subject.edited_passages }.by(1)
      end
    end

    context "when editing an existing row with valid parameters but an empty value," do
      it "deletes the row successfully, returning the deleted instance" do
        expect(
          subject.edit_existing_passage( passage.id, '' )
        ).to be_a( Passage )
      end
      it "changes the resulting SQL diff log" do
        expect{
          subject.edit_existing_passage( passage.id, '' )
        }.to change{ subject.sql_diff_text_log }
      end
      it "increases the number of deleted rows" do
        expect{
          subject.edit_existing_passage( passage.id, '' )
        }.to change{ subject.destroyed_passages }.by(1)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#create_new_passage" do
    context "when creating a new row with valid parameters," do
      it "creates the row" do
        expect(
          subject.create_new_passage( passage.meeting_individual_result_id, passage.passage_type_id, fixture_value )
        ).to be true
      end
      it "sets the new row with the correct source parameters (MIR, passage type, ...)" do
        subject.create_new_passage( passage.meeting_individual_result_id, passage.passage_type_id, fixture_value )
        result_row = Passage.last
        expect( result_row.meeting_individual_result_id ).to eq( passage.meeting_individual_result_id )
        expect( result_row.passage_type_id ).to eq( passage.passage_type_id )
        expect( result_row.team_id ).to eq( passage.team_id )
        expect( result_row.swimmer_id ).to eq( passage.swimmer_id )
        expect( result_row.minutes_from_start ).to eq( minutes )
        expect( result_row.seconds_from_start ).to eq( seconds )
        expect( result_row.hundreds_from_start ).to eq( hundreds )
      end
      it "changes the resulting SQL diff log" do
        expect{
          subject.create_new_passage( passage.meeting_individual_result_id, passage.passage_type_id, fixture_value )
        }.to change{ subject.sql_diff_text_log }
      end
      it "increases the number of created rows" do
        expect{
          subject.create_new_passage( passage.meeting_individual_result_id, passage.passage_type_id, fixture_value )
        }.to change{ subject.new_passages }.by(1)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#is_delta?" do
    it "responds to #is_delta?" do
      expect( subject ).to respond_to( :is_delta? )
    end
    it "returns a boolean" do
      expect( subject.is_delta?( create( :passage) ) ).to eq( true ).or eq( false )
    end
    it "returns true if first passage" do
      expect( passage.get_timing_instance ).not_to eq( passage.get_final_time )
      expect( passage.get_previous_passage ).to be_nil
      expect( subject.is_delta?( passage ) ).to eq( true )
    end
    it "returns false if time swam equals to total time swam" do
      last_passage.minutes  = last_passage.meeting_individual_result.minutes 
      last_passage.seconds  = last_passage.meeting_individual_result.seconds 
      last_passage.hundreds = last_passage.meeting_individual_result.hundreds
      expect( last_passage.get_timing_instance ).to eq( last_passage.get_final_time )
      expect( subject.is_delta?( last_passage ) ).to eq( false )
    end
    it "returns true if time swam smaller than total time swam in previous passage" do
      expect( last_passage.get_previous_passage ).to be_an_instance_of( Passage )
      expect( last_passage.get_timing_instance ).to be < last_passage.get_previous_passage.compute_incremental_time
      expect( subject.is_delta?( last_passage ) ).to eq( true )
    end
    it "returns true if time swam per meter is less than total time swam per meter * 50%" do
      if ! mir_with_pass.is_disqualified
        total_distance = mir_with_pass.event_type.length_in_meters
        total_timing   = mir_with_pass.get_timing_instance.to_hundreds
        mir_with_pass.get_passages.each do |delta_passage|
          #passage.minutes  = passage.minutes 
          #passage.seconds  = passage.seconds 
          #passage.hundreds = passage.hundreds
          expect( delta_passage.get_timing_instance.to_hundreds / delta_passage.compute_distance_swam ).to be <= ( total_timing / total_distance * 1.5 )
          expect( subject.is_delta?( delta_passage ) ).to eq( true )
        end
      end
    end
    it "returns false if time swam per meter is more than total time swam per meter * 50%" do
      if ! mir_with_pass.is_disqualified
        total_distance = mir_with_pass.event_type.length_in_meters
        total_timing   = mir_with_pass.get_timing_instance.to_hundreds
        mir_with_pass.get_passages.each_with_index do |incremental_passage,index|
          if index > 0
            incremental_time = incremental_passage.compute_incremental_time
            if incremental_passage.get_timing_instance.to_hundreds < incremental_time.to_hundreds
              incremental_passage.minutes  = incremental_time.minutes 
              incremental_passage.seconds  = incremental_time.seconds 
              incremental_passage.hundreds = incremental_time.hundreds
              expect( incremental_passage.get_timing_instance.to_hundreds ).to eq( incremental_time.to_hundreds )
              expect( incremental_passage.get_timing_instance.to_hundreds / incremental_passage.compute_distance_swam ).to be >= ( total_timing / total_distance * 1.5 )
              expect( subject.is_delta?( incremental_passage ) ).to eq( false )
            end
          end
        end
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
