# rubocop:disable Style/FrozenStringLiteralComment

require 'rails_helper'
require 'wrappers/timing'

# rubocop:disable Rails/DynamicFindBy
describe SwimmerPersonalBestUpdater, type: :strategy, tag: :swimmer do
  context 'without requested parameters' do
    it 'raises an exception for wrong swimmer parameter' do
      expect { SwimmerPersonalBestUpdater.new }.to raise_error(ArgumentError)
      expect { SwimmerPersonalBestUpdater.new('Wrong type parameter') }.to raise_error(ArgumentError)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with requested parameters' do
    let(:csi_season_type) { SeasonType.find_by(code: 'MASCSI') }
    let(:csi_season)      { csi_season_type.seasons.is_ended.sample }
    let(:subject_swimmer) do
      (team = csi_season.teams.sample) while team.nil?
      team.badges.for_season(csi_season).sample.swimmer
    end
    let(:subject_team) { subject_swimmer.team }

    subject { SwimmerPersonalBestUpdater.new(subject_swimmer) }

    it_behaves_like('(the existance of a method)', [
                      :swimmer
                    ])

    let(:record) { subject.swimmer }
    it_behaves_like('SqlConverter [param: let(:record)]')
    it_behaves_like('SqlConvertable [subject: includee]')

    describe '#parameters,' do
      it 'are the given parameters' do
        expect(subject.swimmer).to eq(subject_swimmer)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#reset_personal_best!,' do
      it 'clears personal best' do
        fix_swimmer = Swimmer.find(23)
        updater     = SwimmerPersonalBestUpdater.new(fix_swimmer)
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        updater.reset_personal_best!(fix_event_by_pool_type)
        expect(fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).is_personal_best.count).to eq(0)
      end
      it 'clears personal best already set' do
        fix_swimmer = Swimmer.find(23)
        updater     = SwimmerPersonalBestUpdater.new(fix_swimmer)
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        updater.set_personal_best!(fix_event_by_pool_type)
        expect(fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).is_personal_best.count).to be > 0
        updater.reset_personal_best!(fix_event_by_pool_type)
        expect(fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).is_personal_best.count).to eq(0)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#reset_all_personal_bests!,' do
      it 'clears personal best already set' do
        subject.scan_for_personal_best!
        subject.reset_all_personal_bests!
        expect(subject_swimmer.meeting_individual_results.is_personal_best.count).to eq(0)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#set_personal_best!,' do
      it 'returns a timing instance if event already swam' do
        fix_swimmer = Swimmer.find(23)
        updater     = SwimmerPersonalBestUpdater.new(fix_swimmer)
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        expect(
          updater.set_personal_best!(fix_event_by_pool_type)
        ).to be_an_instance_of(MeetingIndividualResult)
      end
      it 'sets personal best flag if event already swam' do
        fix_swimmer = Swimmer.find(23)
        updater     = SwimmerPersonalBestUpdater.new(fix_swimmer)
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        updater.reset_personal_best!(fix_event_by_pool_type)
        expect(
          fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).is_personal_best.count
        ).to eq(0)
        updater.set_personal_best!(fix_event_by_pool_type)
        expect(
          fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).is_personal_best.count
        ).to be > 0
      end
      # FIXME: RANDOM FAILURE HERE:
      xit 'sets a time corresponding to the best swam (if swam)' do
        event = EventsByPoolType.not_relays.only_for_meetings
                                .sample
        # DEBUG
        puts "\r\n- subject swimmer: #{subject_swimmer.inspect}"
        puts "=>  event chosen: #{event.i18n_short} => #{event.inspect}"
        if subject_swimmer.meeting_individual_results.for_event_by_pool_type(event).is_not_disqualified.count > 0
          expect(subject.set_personal_best!(event)).to eq(
            SwimmerPersonalBestFinder.new(subject_swimmer)
              .get_best_for_event(event.event_type, event.pool_type)
          )
          expect(subject.set_personal_best!(event)).to eq(
            subject_swimmer.meeting_individual_results.for_event_by_pool_type(event).is_not_disqualified.sort_by_timing(:asc).first.get_timing_instance
          )
        else
          expect(subject.set_personal_best!(event)).to eq(
            SwimmerPersonalBestFinder.new(subject_swimmer)
              .get_best_for_event(event.event_type, event.pool_type)
          )
        end
      end

      # Assumes Leega didn't ever swam 3000 in 25 pool.
      # If he will swim it... not change the spec, but, please, heal Leega
      it 'returns nil if event not already swam' do
        fix_swimmer = Swimmer.find(23)
        updater     = SwimmerPersonalBestUpdater.new(fix_swimmer)
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '3000SL')
        expect(updater.set_personal_best!(fix_event_by_pool_type)).to be_nil
      end
      it 'returns a time swam if swam before or nil if not' do
        event = EventsByPoolType.not_relays.sample
        if subject_swimmer.meeting_individual_results.for_event_by_pool_type(event).is_not_disqualified.count > 0
          expect(subject.set_personal_best!(event)).to be_an_instance_of(MeetingIndividualResult)
          expect(subject_swimmer.meeting_individual_results.for_event_by_pool_type(event).is_personal_best.count).to be > 0
        else
          expect(subject.set_personal_best!(event)).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#scan_for_personal_best!,' do
      it 'sets at least 20 personal bests for Leega' do
        updater = SwimmerPersonalBestUpdater.new(Swimmer.find(23))
        expect(updater.scan_for_personal_best!).to be >= 20
      end
      it 'returns 0 for swimmer without results' do
        updater = SwimmerPersonalBestUpdater.new(create(:swimmer))
        expect(updater.scan_for_personal_best!).to eq(0)
      end
      # FIXME: Raises random failures, depending upon chosen season, current date & current  academic year
      it 'sets a personal best for each event by pool type swam by swimmer' do
        event_swam = 0
        subject.scan_for_personal_best!
        EventsByPoolType.not_relays.each do |event_by_pool_type|
          if subject_swimmer.meeting_individual_results.for_event_by_pool_type(event_by_pool_type).is_not_disqualified.count > 0
            expect(subject_swimmer.meeting_individual_results.for_event_by_pool_type(event_by_pool_type).is_personal_best.count).to be > 0
            event_swam += 1
          else
            expect(subject_swimmer.meeting_individual_results.for_event_by_pool_type(event_by_pool_type).is_personal_best.count).to eq(0)
          end
          expect(subject_swimmer.meeting_individual_results.is_personal_best.count).to be >= event_swam
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
# rubocop:enable Rails/DynamicFindBy, Style/FrozenStringLiteralComment
