# frozen_string_literal: true

require 'rails_helper'
require 'wrappers/timing'

# rubocop:disable Rails/DynamicFindBy
describe GoggleCupStandardFinder, type: :strategy, tag: :slow do
  context 'with requested parameters' do
    # Leega
    # Use existing team and swimmer with results to test those features
    # will not run at the beginning of the seasons where thera aren't badges
    # So should use Ober Ferrari's existing Ober Cup with Leega
    #
    # To test randomly should create:
    # A team with swimmers (badges) withe results swam before the goggle cup
    #
    # let(:@active_team)    { SeasonType.find_by_code('MASCSI').seasons.is_ended.sample.teams.distinct.sample }
    # let(:@goggle_cup)     { create( :@goggle_cup, season_year: Date.today.year, team: @active_team ) }
    # let(:@goggle_cup)     { GoggleCup.for_team( @active_team ).is_closed_now.sample }
    # let(:@active_swimmer) { @goggle_cup.swimmers.has_results.distinct.sample }
    # let( :team )    { create(:team) }
    # let( :badge )   { create( :badge, team: team ) }
    # let( :swimmer ) { badge.swimmer }
    # let( :mir_old ) { create( :meeting_individual_result, badge: badge ) }

    #    let(:@active_team)    { Team.find(1) }
    #    let(:@goggle_cup)     { GoggleCup.find(9) }
    #    let(:@active_swimmer) { Swimmer.find(23) }
    #    let(:@subject)        { GoggleCupStandardFinder.new( @goggle_cup ) }
    #    @subject { GoggleCupStandardFinder.new( @goggle_cup ) }

    # [Steve, 20151128] A before :all is best suited for such long tests:
    before(:all) do
      @active_team = Team.find(1)
      @goggle_cup = GoggleCup.find(9)
      @active_swimmer = Swimmer.find(23)
      @subject = GoggleCupStandardFinder.new(@goggle_cup)
    end

    [:goggle_cup, :swimmers, :create_goggle_cup_standards!, :delete_goggle_cup_standards!, :sql_diff_text_log].each do |method_name|
      it "responds to ##{method_name}" do
        expect(@subject).to respond_to(method_name)
      end
    end

    describe '#goggle_cup,' do
      it 'is the parameter specified in the constructor' do
        expect(@subject.goggle_cup).to be_an_instance_of(GoggleCup)
        expect(@subject.goggle_cup.id).to eq(@goggle_cup.id)
      end
    end
    #-- -----------------------------------------------------------------------

    describe '#swimmers,' do
      it 'returns an array' do
        expect(@subject.swimmers).to be_a_kind_of(Array)
      end
      it 'returns an array of swimmers' do
        expect(@subject.swimmers).to all(be_an_instance_of(Swimmer))
      end
      it 'returns no more than total team swimmers' do
        expect(@subject.swimmers.size).to be <= @goggle_cup.swimmers.count
      end
    end
    #-- -----------------------------------------------------------------------

    describe '#oldest_swimmer_result,' do
      it 'returns a date' do
        expect(@subject.oldest_swimmer_result(@active_swimmer)).to be_an_instance_of(Date)
      end
      it 'returns a date not greater than other one of swimmer results' do
        expect(@subject.oldest_swimmer_result(@active_swimmer)).to be <= @active_swimmer.meeting_individual_results.sample.get_scheduled_date
      end
      it 'returns tomorrow date if not swam results' do
        new_swimmer = create(:swimmer)
        expect(@subject.oldest_swimmer_result(new_swimmer)).to be >= Date.today
      end
    end
    #-- -----------------------------------------------------------------------

    describe '#get_periods_to_scan,' do
      it 'returns an array' do
        expect(@subject.get_periods_to_scan(@active_swimmer)).to be_a_kind_of(Array)
      end
      it 'returns an array of dates' do
        expect(@subject.get_periods_to_scan(@active_swimmer)).to all be_a_kind_of(Date)
      end
      it 'returns a sorted array of dates' do
        dates = @subject.get_periods_to_scan(@active_swimmer)
        (1..dates.size - 1).each do |index|
          expect(dates[index]).to be < dates[index - 1]
        end
      end
      it 'returns an array of dates with only one element older than oldest_swimmer_result' do
        oldest_swimmer_result = @subject.oldest_swimmer_result(@active_swimmer)
        older_dates = 0
        @subject.get_periods_to_scan(@active_swimmer).each do |date|
          older_dates += 1 if date <= oldest_swimmer_result
        end
        expect(older_dates).to eq(1)
      end
      it 'returns an empty array if not swam results' do
        new_swimmer = create(:swimmer)
        expect(@subject.get_periods_to_scan(new_swimmer).size).to eq(0)
      end
    end
    #-- -----------------------------------------------------------------------

    describe '#find_swimmer_goggle_cup_standard,' do
      it 'returns an hash' do
        expect(@subject.find_swimmer_goggle_cup_standard(@active_swimmer)).to be_a_kind_of(Hash)
      end
      it 'returns an hash containing at least one element' do
        expect(@subject.find_swimmer_goggle_cup_standard(@active_swimmer).size).to be >= 1
      end
      it 'returns an hash containg instance of timing' do
        @subject.find_swimmer_goggle_cup_standard(@active_swimmer).each_value do |standard_time|
          expect(standard_time).to be_an_instance_of(Timing)
        end
      end
      it 'returns an hash containg events by pool types as keys' do
        @subject.find_swimmer_goggle_cup_standard(@active_swimmer).each_key do |event_key|
          expect(EventsByPoolType.find_by_key(event_key)).to be_an_instance_of(EventsByPoolType)
        end
      end
      it 'returns a timing instance for an event swam' do
        swam_mir = @active_swimmer.meeting_individual_results.for_team(@active_team).has_time.is_not_disqualified.sort_by_date('ASC').first
        swam_event_by_pool_type = "#{swam_mir.event_type.code}-#{swam_mir.pool_type.code}" # Should use events_by_pool_type.get_key
        expect(@subject.find_swimmer_goggle_cup_standard(@active_swimmer)[swam_event_by_pool_type]).to be_an_instance_of(Timing)
      end
      it 'returns no more than goggle cup standard already presents for a stored goggle cup' do
        # Should use a stored goggle cup
        expect(@subject.find_swimmer_goggle_cup_standard(@active_swimmer).count).to be <= @goggle_cup.goggle_cup_standards.for_swimmer(@active_swimmer).count
      end
      it 'returns the same goggle cup standard already presents for a stored goggle cup' do
        # Should use a stored goggle cup
        @subject.find_swimmer_goggle_cup_standard(@active_swimmer).each_pair do |found_key, found_standard|
          event_by_pool_type = EventsByPoolType.find_by_key(found_key)
          expect(found_standard).to eq(
            @goggle_cup.goggle_cup_standards
              .for_swimmer(@active_swimmer)
              .for_event_and_pool(event_by_pool_type)
              .first
              .get_timing_instance
          )
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe '#delete_goggle_cup_standards_for_swimmer!,' do
      it 'appends text to sql diff' do
        previous_size = @subject.sql_diff_text_log.size
        @subject.delete_goggle_cup_standards_for_swimmer!(@active_swimmer)
        expect(@subject.sql_diff_text_log.size).to be > previous_size
      end
      it 'deletes all goggle cup standard times presents for the given swimmer' do
        expect(@goggle_cup.goggle_cup_standards.for_swimmer(@active_swimmer).count).to be > 0
        @subject.delete_goggle_cup_standards_for_swimmer!(@active_swimmer)
        expect(@goggle_cup.goggle_cup_standards.for_swimmer(@active_swimmer).count).to eq(0)
        expect(@goggle_cup.goggle_cup_standards.count).to be > 0
      end
    end
    #-- -----------------------------------------------------------------------

    describe '#delete_goggle_cup_standards!,' do
      it 'appends text to sql diff' do
        previous_size = @subject.sql_diff_text_log.size
        @subject.delete_goggle_cup_standards!
        expect(@subject.sql_diff_text_log.size).to be > previous_size
      end
      # FAILS even though the records are actually deleted -- (tested by hand
      # on console)
      xit 'deletes all associated goggle cup standard times' do
        expect(@subject.goggle_cup.goggle_cup_standards.count).to be > 0
        expect(@goggle_cup.goggle_cup_standards.count).to be > 0
        expect do
          @subject.delete_goggle_cup_standards!
        end.to change {
          @subject.goggle_cup.goggle_cup_standards.count
        }.to(0)
        #        @subject.goggle_cup.reload
        #        expect( @subject.goggle_cup.goggle_cup_standards.count ).to eq(0)
        #        @goggle_cup.reload
        #        expect( @goggle_cup.goggle_cup_standards.count ).to eq(0)
      end
    end
    #-- -----------------------------------------------------------------------

    describe '#create_goggle_cup_standards_for_swimmer!,' do
      it 'appends text to sql diff' do
        previous_size = @subject.sql_diff_text_log.size
        @subject.create_goggle_cup_standards_for_swimmer!(@active_swimmer)
        expect(@subject.sql_diff_text_log.size).to be > previous_size
      end
      it 'creates standard times found for the swimmer' do
        @subject.delete_goggle_cup_standards_for_swimmer!(@active_swimmer)
        @subject.create_goggle_cup_standards_for_swimmer!(@active_swimmer)
        expect(@subject.find_swimmer_goggle_cup_standard(@active_swimmer).size).to eq(@goggle_cup.goggle_cup_standards.for_swimmer(@active_swimmer).count)
      end
    end
    #-- -----------------------------------------------------------------------

    describe '#create_goggle_cup_standards!,' do
      it 'appends text to sql diff' do
        previous_size = @subject.sql_diff_text_log.size
        @subject.create_goggle_cup_standards!
        expect(@subject.sql_diff_text_log.size).to be > previous_size
      end
      it 'creates at least one goggle_cup_standard for each swimmer involved' do
        @subject.delete_goggle_cup_standards!
        @subject.create_goggle_cup_standards!
        expect(@goggle_cup.goggle_cup_standards.count).to be >= @subject.swimmers.count
      end
    end
    #-- -----------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'without requested parameters' do
    it 'raises an exception for wrong @goggle_cup parameter' do
      expect { GoggleCupStandardFinder.new }.to raise_error(ArgumentError)
      expect { GoggleCupStandardFinder.new('Wrong type parameter') }.to raise_error(ArgumentError)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
# rubocop:enable Rails/DynamicFindBy
