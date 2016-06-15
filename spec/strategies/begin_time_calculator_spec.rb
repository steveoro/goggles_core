# encoding: utf-8
require 'spec_helper'

require 'begin_time_calculator'


describe BeginTimeCalculator, type: :strategy do

  it_behaves_like( "(the existance of a class method)", [
    :compute_from_previous, :compute_for_all
  ] )
  #-- -------------------------------------------------------------------------
  #++


  describe "self.compute_from_previous" do
    let(:scheduled_date_string)       { "#{ 2000 + ((rand * 100) % 15).to_i }-11-01" }
    let(:scheduled_date)              { Date.parse( scheduled_date_string ) }
    let(:event_order)                 { (1 + rand * 100).to_i }
    let(:athletes_tot)                { (1 + rand * 50).to_i }
    let(:base_time_mins)              { 1 + (rand * 15).to_i }
    let(:result) do
      subject.class.compute_from_previous(
        scheduled_date,
        event_order,
        athletes_tot,
        base_time_mins
      )
    end

    let(:optimistic_duration_mins) do
      ( (event_order - 1) + (athletes_tot < 8 ? 8 : athletes_tot) / 8 ) *
      (base_time_mins.to_i < 2 ? 2 : base_time_mins.to_i)
    end
    let(:pessimistic_duration_mins)   { optimistic_duration_mins.to_f * 1.6 }

    let(:optimistic_guess) do
      Time.utc(
        scheduled_date.year, scheduled_date.month, scheduled_date.day,
        8,
        0
      ) + (optimistic_duration_mins * 60)
    end
    let(:pessimistic_guess) do
      Time.utc(
        scheduled_date.year, scheduled_date.month, scheduled_date.day,
        8,
        0
      ) + (pessimistic_duration_mins * 60)
    end

    it "always returns a Time instance" do
      expect( result ).to be_an_instance_of( Time )
    end

    it "returns a fair guess not below an optimistic guess" do
# DEBUG
#      puts "\r\nEvent ##{event_order}, athletes_tot: #{athletes_tot}, base_time_mins: #{base_time_mins}"
#      puts "=> result: #{result}, optimistic_guess: #{optimistic_guess}, pessimistic_guess: #{pessimistic_guess}"
      expect( result.to_f ).to be >= optimistic_guess.to_f
    end

    it "returns a fair guess not above a pessimistic guess" do
# DEBUG
#      puts "\r\nEvent ##{event_order}, athletes_tot: #{athletes_tot}, base_time_mins: #{base_time_mins}"
#      puts "=> result: #{result}, optimistic_guess: #{optimistic_guess}, pessimistic_guess: #{pessimistic_guess}"
      expect( result.to_f ).to be <= pessimistic_guess.to_f
    end
    #-- -----------------------------------------------------------------------
    #++

    context "when given a previous begin time," do
      let(:previous_begin_time)         { Time.parse( scheduled_date_string + " #{ '%02d' % (8 + rand * 9).to_i }:00") }
      let(:result_with_prev_begin_time) do
        subject.class.compute_from_previous(
          scheduled_date,
          event_order,
          athletes_tot,
          base_time_mins,
          previous_begin_time
        )
      end

      it "returns a guess that is greater than the previous begin time" do
# DEBUG
#        puts "\r\nEvent ##{event_order}, athletes_tot: #{athletes_tot}, base_time_mins: #{base_time_mins}"
#        puts "=> result: #{result_with_prev_begin_time}, previous_begin_time: #{previous_begin_time}, optimistic_guess: #{optimistic_guess}, pessimistic_guess: #{pessimistic_guess}"
        expect( result_with_prev_begin_time.to_f ).to be > previous_begin_time.to_f
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "self.get_esteemed_heat_number()" do
    [
      [ 80, 8, 1, 10 ],
      [ 63, 8, 1,  6 ]
    ].each do |total_athletes, pool_lanes_total, event_order, min_accepted_result|
      it "returns a value not below than the min. accepted (#{min_accepted_result})" do
        expect(
          subject.class.get_esteemed_heat_number( total_athletes, pool_lanes_total, event_order )
        ).to be >= min_accepted_result
      end
    end
  end


  describe "self.get_esteemed_duration_in_mins()" do
    [
      [ 1,  2,  2 ],
      [ 2,  2,  4 ],
      [ 2, 10, 20 ],
      [ 3, 15, 45 ]
    ].each do |base_time_mins, heat_number_approx, min_accepted_result|
      it "returns a value not below than the min. accepted (#{min_accepted_result})" do
        expect(
          subject.class.get_esteemed_duration_in_mins( base_time_mins, heat_number_approx )
        ).to be >= min_accepted_result
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "self.compute_for_all" do
    let( :non_processable_meeting ) { create( :meeting) }
    let( :meeting_with_entries)     { Meeting.find(14101) }
    let( :meeting_with_results)     { Meeting.find(13101) }

    it "returns false if the supplied meeting is not processable (doesn't have entries or results)" do
      expect(
        subject.class.compute_for_all( non_processable_meeting, '' )
      ).to be false
    end

    context "for a processable meeting," do
      it "returns true" do
        expect(
          subject.class.compute_for_all( meeting_with_entries, '', true )
        ).to be true
      end

      it "adds contents to the sql diff text variable" do
        sql_diff_text = ''
        expect(
          subject.class.compute_for_all( meeting_with_results, sql_diff_text, true )
        ).to be true
        expect( sql_diff_text.length ).to be > 0
      end

      it "adds the SQL comment 'Using RESULTS' to the sql diff text when using results for the calc" do
        sql_diff_text = ''
        expect(
          subject.class.compute_for_all( meeting_with_results, sql_diff_text )
        ).to be true
        expect( sql_diff_text ).to include( "-- Using RESULTS" )
# DEBUG
#        puts "\r\n" << sql_diff_text
      end

      # [Steve, 20150103] There is no fixture data for Meetings with only
      # entries and NO results. So, the case where the entries are used for
      # heat computation instead of the results it cannot be recreated easily.
      # (still missing a complete meeting entry factory)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end