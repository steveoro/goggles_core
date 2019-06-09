# frozen_string_literal: true

require 'rails_helper'
require 'wrappers/timing'

# rubocop:disable Rails/DynamicFindBy
describe SwimmerPersonalBestFinder, type: :strategy do
  context 'without requested parameters' do
    it 'raises an exception for wrong swimmer parameter' do
      expect { SwimmerPersonalBestFinder.new }.to raise_error(ArgumentError)
      expect { SwimmerPersonalBestFinder.new('Wrong type parameter') }.to raise_error(ArgumentError)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with requested parameters' do
    let(:csi_season_type) { SeasonType.find_by(code: 'MASCSI') }
    let(:csi_season)      { csi_season_type.seasons.is_ended.sample }
    let(:active_swimmer) do
      (team = csi_season.teams.sample) while team.nil?
      team.badges.for_season(csi_season).sample.swimmer
    end
    let(:active_team) { active_swimmer.team }

    subject { SwimmerPersonalBestFinder.new(active_swimmer) }

    it_behaves_like('(the existance of a method)', [
                      :swimmer
                    ])

    describe '#parameters,' do
      it 'are the given parameters' do
        expect(subject.swimmer).to eq(active_swimmer)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_closed_seasons_involved_into, ' do
      it 'returns an array' do
        expect(subject.get_closed_seasons_involved_into).to be_a_kind_of(ActiveRecord::Relation)
      end
      it 'returns an array of seasons' do
        expect(subject.get_closed_seasons_involved_into).to all(be_an_instance_of(Season))
      end
      it 'returns an array of ended seasons' do
        subject.get_closed_seasons_involved_into.each do |season|
          expect(season.is_season_ended_at).to be true
        end
      end
      it 'returns an array of sorted seasons' do
        seasons = subject.get_closed_seasons_involved_into
        elem = 1
        while elem < seasons.size
          expect(seasons[elem].begin_date).to be <= seasons[elem - 1].begin_date
          elem += 1
        end
      end
      it 'returns an array of seasons of given season type' do
        subject.get_closed_seasons_involved_into(csi_season_type).each do |season|
          expect(season.season_type.code).to eq(csi_season_type.code)
        end
      end
      it 'returns an array of seasons same season type if given' do
        expect(subject.get_closed_seasons_involved_into(csi_season_type).map { |s| s.season_type.code }.uniq.count).to eq(1)
      end
      it 'returns an array of seasons of different season types if any' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        expect(fix_sbf.get_closed_seasons_involved_into.map { |s| s.season_type.code }.uniq.count).to be > 1
      end
      it 'returns an array of seasons ended befaore a certain date if given' do
        ended_before = '01-01-2015'.to_date
        seasons = subject.get_closed_seasons_involved_into(nil, ended_before)
        seasons.each do |season|
          expect(season.end_date).to be < ended_before
        end
      end
      it 'returns few seasons for Leega if a 2015 date given' do
        ended_before = '01-01-2015'.to_date
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        expect(fix_sbf.get_closed_seasons_involved_into(nil, ended_before).count).to be < fix_sbf.get_closed_seasons_involved_into.count
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_current_seasons_involved_into, ' do
      it 'returns an array' do
        expect(subject.get_current_seasons_involved_into).to be_a_kind_of(ActiveRecord::Relation)
      end
      it 'returns an array of seasons' do
        expect(subject.get_current_seasons_involved_into).to all(be_an_instance_of(Season))
      end
      it 'returns an array of not ended seasons' do
        subject.get_current_seasons_involved_into.each do |season|
          expect(season.is_season_ended_at).to be false
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_contemporary_seasons_involved_into, ' do
      it 'returns an array' do
        expect(subject.get_contemporary_seasons_involved_into(csi_season)).to be_a_kind_of(ActiveRecord::Relation)
      end
      it 'returns an array of seasons' do
        expect(subject.get_contemporary_seasons_involved_into(csi_season)).to all(be_an_instance_of(Season))
      end
      it 'returns an array of seasons conteporary of given one' do
        subject.get_contemporary_seasons_involved_into(csi_season).each do |season|
          expect(season.begin_date).to be <= csi_season.end_date
          expect(season.end_date).to be >= csi_season.begin_date
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_involved_season_last_best_for_event,' do
      it 'returns a timing instance if event already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '50FA')
        fix_pool    = PoolType.find_by(code: '25')
        expect(fix_sbf.get_involved_season_last_best_for_event(fix_sbf.get_closed_seasons_involved_into, fix_event, fix_pool)).to be_an_instance_of(Timing)
      end
      it 'returns nil if event not already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '100MI')
        fix_pool    = PoolType.find_by(code: '50')
        expect(fix_sbf.get_involved_season_last_best_for_event(fix_sbf.get_closed_seasons_involved_into, fix_event, fix_pool)).to be_nil
      end
      it 'returns nil if event not already swam in the correct season type' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '200FA')
        fix_pool    = PoolType.find_by(code: '25')
        expect(fix_sbf.get_involved_season_last_best_for_event(fix_sbf.get_closed_seasons_involved_into(csi_season_type), fix_event, fix_pool)).to be_nil
      end
      it 'returns a time swam in the past season if any' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '200MI')
        fix_pool    = PoolType.find_by(code: '25')
        fix_seasons = csi_season_type.seasons.is_ended_before(Date.new(2015, 11, 15)).sort_season_by_begin_date('DESC')
        expect(fix_swimmer.meeting_individual_results.is_not_disqualified.for_season(fix_seasons.first).for_pool_type(fix_pool).for_event_type(fix_event).count).to be > 0
        expect(fix_sbf.get_involved_season_last_best_for_event(fix_seasons, fix_event, fix_pool)).to eq(fix_swimmer.meeting_individual_results.is_not_disqualified.for_season(fix_seasons.first).for_pool_type(fix_pool).for_event_type(fix_event).sort_by_timing('ASC').first.get_timing_instance)
      end
      it 'returns a time swam in an older season if not swimmed in the past one' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '400MI')
        fix_pool    = PoolType.find_by(code: '50')
        fix_seasons = csi_season_type.seasons.is_ended_before(Date.new(2015, 11, 15)).sort_season_by_begin_date('DESC')
        expect(fix_swimmer.meeting_individual_results.is_not_disqualified.for_season(fix_seasons.first).for_pool_type(fix_pool).for_event_type(fix_event).count).to eq(0)
        expect(fix_sbf.get_involved_season_last_best_for_event(fix_seasons, fix_event, fix_pool)).to be_an_instance_of(Timing)
      end
      it 'returns a time swam if swam before or nil if not' do
        event = EventsByPoolType.not_relays.sample
        if active_swimmer.meeting_individual_results.is_not_disqualified.for_closed_seasons.for_pool_type(event.pool_type).for_event_type(event.event_type).count > 0
          expect(subject.get_involved_season_last_best_for_event(subject.get_closed_seasons_involved_into, event.event_type, event.pool_type)).to be_an_instance_of(Timing)
        else
          expect(subject.get_involved_season_last_best_for_event(subject.get_closed_seasons_involved_into, event.event_type, event.pool_type)).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_involved_season_best_for_event,' do
      it 'returns a timing instance if event already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '50FA')
        fix_pool    = PoolType.find_by(code: '25')
        expect(fix_sbf.get_involved_season_best_for_event(fix_sbf.get_contemporary_seasons_involved_into(Season.find(141)), fix_event, fix_pool)).to be_an_instance_of(Timing)
      end
      it 'returns nil if event not already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '100MI')
        fix_pool    = PoolType.find_by(code: '50')
        expect(fix_sbf.get_involved_season_best_for_event(fix_sbf.get_contemporary_seasons_involved_into(Season.find(141)), fix_event, fix_pool)).to be_nil
      end
      it 'returns nil if event not already swam in the seasons' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '200FA')
        fix_pool    = PoolType.find_by(code: '25')
        expect(fix_sbf.get_involved_season_best_for_event(fix_sbf.get_closed_seasons_involved_into(csi_season_type), fix_event, fix_pool)).to be_nil
      end

      context 'for a swimmer WITHOUT results,' do
        it 'returns nil' do
          event = EventsByPoolType.not_relays.sample
          swimmer_w_o_results = create(:swimmer)
          sbf = SwimmerPersonalBestFinder.new(swimmer_w_o_results)
          expectation = sbf.get_involved_season_best_for_event(
            sbf.get_contemporary_seasons_involved_into(csi_season),
            event.event_type,
            event.pool_type
          )
          expect(expectation).to be nil
        end
      end

      context 'for a swimmer WITH results for the specified parameters,' do
        it 'returns nil' do
          # Get a random MIR from a couple of years ago, with  a range radius of 2 years:
          rnd_mir = MeetingIndividualResult.joins(:meeting, :season, :meeting_session, :meeting_event, :pool_type)
                                           .includes(:meeting, :season, :meeting_session, :meeting_event, :pool_type)
                                           .where(['(meetings.header_date > ?) AND (meetings.header_date > ?)',
                                                   Date.today - 4.years, Date.today - 2.years])
                                           .limit(500).min { 0.5 - rand }

          sbf = SwimmerPersonalBestFinder.new(rnd_mir.swimmer)
          expectation = sbf.get_involved_season_best_for_event(
            sbf.get_contemporary_seasons_involved_into(rnd_mir.season),
            rnd_mir.meeting_event.event_type,
            rnd_mir.pool_type
          )
          expect(expectation).to be_a(Timing)
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_involved_season_last_best_for_key,' do
      it 'returns a time swam if swam before or nil if not' do
        event = EventsByPoolType.not_relays.sample
        if active_swimmer.meeting_individual_results.is_not_disqualified.for_closed_seasons.for_pool_type(event.pool_type).for_event_type(event.event_type).count > 0
          expect(subject.get_involved_season_last_best_for_key(subject.get_closed_seasons_involved_into, event.get_key)).to be_an_instance_of(Timing)
        else
          expect(subject.get_involved_season_last_best_for_key(subject.get_closed_seasons_involved_into, event.get_key)).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_season_type_best_for_event,' do
      it 'returns a timing instance if event already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '50FA')
        fix_pool    = PoolType.find_by(code: '25')
        expect(fix_sbf.get_season_type_best_for_event(csi_season_type, fix_event, fix_pool)).to be_an_instance_of(Timing)
      end
      it 'returns nil if event not already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '100MI')
        fix_pool    = PoolType.find_by(code: '50')
        expect(fix_sbf.get_season_type_best_for_event(csi_season_type, fix_event, fix_pool)).to be_nil
      end
      it 'returns a time swam if swam before or nil if not' do
        event = EventsByPoolType.not_relays.sample
        if active_swimmer.meeting_individual_results.is_not_disqualified.for_season_type(csi_season_type).for_pool_type(event.pool_type).for_event_type(event.event_type).count > 0
          expect(subject.get_season_type_best_for_event(csi_season_type, event.event_type, event.pool_type)).to be_an_instance_of(Timing)
        else
          expect(subject.get_season_type_best_for_event(csi_season_type, event.event_type, event.pool_type)).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_best_for_event,' do
      it 'returns a timing instance if event already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '50FA')
        fix_pool    = PoolType.find_by(code: '25')
        expect(fix_sbf.get_best_for_event(fix_event, fix_pool)).to be_an_instance_of(Timing)
      end
      it 'returns nil if event not already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event   = EventType.find_by(code: '100MI')
        fix_pool    = PoolType.find_by(code: '50')
        expect(fix_sbf.get_best_for_event(fix_event, fix_pool)).to be_nil
      end
      it 'returns a time swam if swam before or nil if not' do
        event = EventsByPoolType.not_relays.sample
        if active_swimmer.meeting_individual_results.is_not_disqualified.for_pool_type(event.pool_type).for_event_type(event.event_type).count > 0
          expect(subject.get_best_for_event(event.event_type, event.pool_type)).to be_an_instance_of(Timing)
        else
          expect(subject.get_best_for_event(event.event_type, event.pool_type)).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_best_mir_for_event,' do
      it 'returns a meeting individual result' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        updater     = SwimmerPersonalBestUpdater.new(fix_swimmer)
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        updater.set_personal_best!(fix_event_by_pool_type)
        expect(
          fix_sbf.get_best_mir_for_event(fix_event_by_pool_type.event_type, fix_event_by_pool_type.pool_type)
        ).to be_an_instance_of(MeetingIndividualResult)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    # Test this feature with real data for praticity
    # Sure that Leega swam 25FA more than two times in 25 pool
    # and has been disqualified at least one time in 100MI (huncle dog)
    describe '#is_personal_best?,' do
      it 'returns a boolean' do
        result = active_swimmer.meeting_individual_results.sample
        expect(subject.is_personal_best?(result)).to eq(true).or(eq(false))
      end
      it 'returns true if personal best' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        updater     = SwimmerPersonalBestUpdater.new(fix_swimmer)
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        updater.set_personal_best!(fix_event_by_pool_type)
        best_result = fix_sbf.get_best_mir_for_event(fix_event_by_pool_type.event_type, fix_event_by_pool_type.pool_type)
        expect(fix_sbf.is_personal_best?(best_result)).to eq(true)
      end
      it 'returns false if not personal best' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        worst_result = fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).sort_by_timing('DESC').first
        expect(fix_sbf.is_personal_best?(worst_result)).to eq(false)
      end
      it 'returns false if disqualified' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '100MI')
        disqualified_result = fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).is_disqualified.first
        expect(fix_sbf.is_personal_best?(disqualified_result)).to eq(false)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_best_timing_for_meeting,' do
      it 'returns a timing instance if event already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_meeting = Meeting.find(14_201)
        fix_event   = EventType.find_by(code: '50FA')
        fix_pool    = PoolType.find_by(code: '25')
        expect(fix_sbf.get_best_timing_for_meeting(fix_meeting, fix_event, fix_pool)).to be_an_instance_of(Timing)
      end
      it 'returns nil if event not already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_meeting = Meeting.find(14_201)
        fix_event   = EventType.find_by(code: '100MI')
        fix_pool    = PoolType.find_by(code: '50')
        expect(fix_sbf.get_best_timing_for_meeting(fix_meeting, fix_event, fix_pool)).to be_nil
      end
      it 'returns a time swam if swam before or nil if not' do
        event = EventsByPoolType.not_relays.sample
        meeting = csi_season.meetings.sample
        if active_swimmer.meeting_individual_results.is_not_disqualified.for_meeting_editions(meeting).for_pool_type(event.pool_type).for_event_type(event.event_type).count > 0
          expect(subject.get_best_timing_for_meeting(meeting, event.event_type, event.pool_type)).to be_an_instance_of(Timing)
        else
          expect(subject.get_best_timing_for_meeting(meeting, event.event_type, event.pool_type)).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_entry_best_timing,' do
      it 'returns a timing instance if event already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_meeting = Meeting.find(14_201)
        fix_event   = EventType.find_by(code: '50FA')
        fix_pool    = PoolType.find_by(code: '25')
        fix_badge   = create(:badge, entry_time_type: EntryTimeType.find_by(code: 'P'))
        expect(fix_sbf.get_entry_best_timing(fix_badge, fix_meeting, fix_event, fix_pool)).to be_an_instance_of(Timing)
      end
      it 'returns nil if event not already swam' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_meeting = Meeting.find(14_201)
        fix_event   = EventType.find_by(code: '100MI')
        fix_pool    = PoolType.find_by(code: '50')
        fix_badge   = fix_swimmer.badges.where(season: 142).first
        expect(fix_sbf.get_entry_best_timing(fix_badge, fix_meeting, fix_event, fix_pool)).to be_nil
      end
      it 'returns nil if manual mode' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_meeting = Meeting.find(14_201)
        fix_event   = EventType.find_by(code: '100MI')
        fix_pool    = PoolType.find_by(code: '50')
        fix_badge   = create(:badge, entry_time_type: EntryTimeType.find_by(code: 'M'))
        expect(fix_sbf.get_entry_best_timing(fix_badge, fix_meeting, fix_event, fix_pool)).to be_nil
      end
      it 'returns converted time if event not already swam in given pool type, but in other pool_type' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_meeting = Meeting.find(15_101)
        fix_event   = EventType.find_by(code: '100MI')
        fix_pool    = PoolType.find_by(code: '50')
        other_pool  = PoolType.find_by(code: '25')
        fix_badge   = fix_swimmer.badges.where(season: 151).first
        expect(fix_sbf.get_entry_best_timing(fix_badge, fix_meeting, fix_event, other_pool)).to be_an_instance_of(Timing)
        expect(fix_sbf.get_entry_best_timing(fix_badge, fix_meeting, fix_event, fix_pool, true)).to be_an_instance_of(Timing)
      end
      # Use Leega with FIN events
      it 'returns a time if swimmer swam event type in any pool type' do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerPersonalBestFinder.new(fix_swimmer)
        fix_meeting = Meeting.find(15_101)
        fix_badge   = fix_swimmer.badges.where(season: 151).first
        PoolType.only_for_meetings.each do |fix_pool|
          EventType.are_not_relays.for_fin_calculation.each do |fix_event|
            # debug
            # puts fix_pool.code + '-' + fix_event.code
            expect(fix_sbf.get_entry_best_timing(fix_badge, fix_meeting, fix_event, fix_pool, true)).to be_an_instance_of(Timing)
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
# rubocop:enable Rails/DynamicFindBy
