# frozen_string_literal: true

require 'rails_helper'

shared_examples_for '(existance of meeting stats relation of swimmers)' do |method_name_array|
  method_name_array.each do |method_name|
    it "responds to ##{method_name}" do
      expect(subject).to respond_to(method_name)
    end

    it "#{method_name} returns a list of swimmer instances" do
      subject.send(method_name.to_sym).each do |item|
        expect(item).to be_an_instance_of(Swimmer)
      end
    end
  end
end

shared_examples_for '(existance of meeting stats relation of meeting individual results)' do |method_name_array|
  method_name_array.each do |method_name|
    it "responds to ##{method_name}" do
      expect(subject).to respond_to(method_name)
    end

    it "#{method_name} returns a list of swimmer instances" do
      subject.send(method_name.to_sym).each do |item|
        expect(item).to be_an_instance_of(MeetingIndividualResult)
      end
    end
  end
end
# =============================================================================

describe MeetingStatCalculator, type: :model do
  # Pre-loaded seeded last CSI season and some acquired FIN
  before(:all) do
    @seeded_meets = [12_101, 12_104, 12_105, 13_101, 13_102, 13_103, 13_104, 13_105, 13_106, 15_216, 14_216, 14_101, 14_105]
    @csi_meets = [12_101, 12_104, 12_105, 13_101, 13_105, 14_101, 14_105]
    @meets_with_entries = [14_104, 14_105, 15_101, 15_102, 15_103]
    @meets_without_entries = [12_101, 12_102, 12_103, 13_223, 15_207]
    @meets_with_standard_points = [13_213, 13_216, 13_223, 14_213, 14_216, 15_216]
    @meets_without_relays = [13_106, 14_207, 13_207, 13_213, 14_213]
    @meets_with_std_relays = [14_216, 15_216, 14_201, 15_201]
  end

  let(:meeting)                   { Meeting.find(@seeded_meets.sample) }
  let(:csi_meeting)               { Meeting.find(@csi_meets.sample) }
  let(:meet_with_entries)         { Meeting.find(@meets_with_entries.sample) }
  let(:meet_without_entries)      { Meeting.find(@meets_without_entries.sample) }
  let(:meet_with_standard_points) { Meeting.find(@meets_with_standard_points.sample) }
  let(:meet_without_relays)       { Meeting.find(@meets_without_relays.sample) }
  let(:meet_with_std_relays)      { Meeting.find(@meets_with_std_relays.sample) }

  subject { MeetingStatCalculator.new(meeting) }

  describe '[fixed data sets]' do
    it 'meeting set has results' do
      @seeded_meets.each do |meeting_id|
        meeting = Meeting.find(meeting_id)
        expect(meeting.are_results_acquired).to be true
        expect(meeting.meeting_individual_results.count).to be > 0
      end
    end
    it 'csi meeting set has results fro CSI Ober Ferrari' do
      @csi_meets.each do |meeting_id|
        csi_meeting = Meeting.find(meeting_id)
        expect(csi_meeting.are_results_acquired).to be true
        expect(meeting.meeting_individual_results.count).to be > 0
        expect(meeting.meeting_individual_results.for_team(Team.find(1)).count).to be > 0
      end
    end
    it 'meet_with_entries set has entries' do
      @meets_with_entries.each do |meeting_id|
        meet_with_entries = Meeting.find(meeting_id)
        expect(meet_with_entries.has_start_list).to be true
        expect(meet_with_entries.meeting_entries.count).to be > 0
      end
    end
    it "meet_without_entries set hasn't entries" do
      @meets_without_entries.each do |meeting_id|
        meet_without_entries = Meeting.find(meeting_id)
        expect(meet_without_entries.has_start_list).to be false
        expect(meet_without_entries.meeting_entries.count).to eq(0)
      end
    end
    it 'meet_with_standard_points set has standard points' do
      @meets_with_standard_points.each do |meeting_id|
        meet_with_standard_points = Meeting.find(meeting_id)
        expect(meet_with_standard_points.are_results_acquired).to be true
        expect(meet_with_standard_points.meeting_individual_results.count).to be > 0
        expect(meet_with_standard_points.meeting_individual_results.has_points.count).to be > 0
      end
    end
    it "meet_without_relays set hasn't relay results" do
      @meets_without_relays.each do |meeting_id|
        meet_without_relays = Meeting.find(meeting_id)
        expect(meet_without_relays.are_results_acquired).to be true
        expect(meet_without_relays.meeting_individual_results.count).to be > 0
        expect(meet_without_relays.meeting_relay_results.count).to eq(0)
      end
    end
  end

  describe '[a well formed instance]' do
    it_behaves_like('(the existance of a method returning numeric values)', [:get_entries_count, :get_entered_swimmers_count, :get_swimmers_count, :get_results_count, :get_teams_count, :get_disqualifieds_count, :get_average, :get_over_target_count])

    it_behaves_like('(existance of meeting stats relation of swimmers)', [
                      # Methods
                      :get_oldest_swimmers,
                      :get_oldest_swimmers
                    ])

    it_behaves_like('(existance of meeting stats relation of meeting individual results)', [
                      # Methods
                      :get_best_standard_scores,
                      :get_worst_standard_scores
                    ])

    it 'meeting is the one used in costruction' do
      expect(subject.meeting).to eq(meeting)
    end

    it 'has a valid meeting instance' do
      expect(subject.get_meeting).to be_an_instance_of(Meeting)
    end

    describe '#has_results?' do
      it 'returns true for a meeting with results' do
        expect(subject.has_results?).to be true
      end
      it 'returns false for a meeting without results' do
        new_meeting = create(:meeting)
        stat_without_results = MeetingStatCalculator.new(new_meeting)
        expect(stat_without_results.has_results?).to be false
      end
    end

    describe '#has_relasys?' do
      it 'returns true for a meeting with relays' do
        stat_csi = MeetingStatCalculator.new(csi_meeting)
        expect(stat_csi.has_relays?).to be true
      end
      it 'returns false for a meeting without relays' do
        stat_without_relays = MeetingStatCalculator.new(meet_without_relays)
        expect(stat_without_relays.has_relays?).to be false
      end
      it 'returns false for a meeting without results' do
        new_meeting = create(:meeting)
        stat_without_results = MeetingStatCalculator.new(new_meeting)
        expect(stat_without_results.has_relays?).to be false
      end
    end

    describe '#has_entries?' do
      it 'returns true for a meeting with entries' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        expect(stat_with_entries.has_entries?).to be true
      end
      it 'returns false for a meeting without entries' do
        new_meeting = create(:meeting)
        stat_without_entries = MeetingStatCalculator.new(new_meeting)
        expect(stat_without_entries.has_entries?).to be false
      end
    end

    describe '#get_teams' do
      it 'returns an array of teams for a meeting with results' do
        teams = subject.get_teams
        expect(teams).to all(be_an_instance_of(Team))
      end
      it 'returns an array of teams for a meeting with entries' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        teams = stat_with_entries.get_teams
        expect(teams).to all(be_an_instance_of(Team))
      end
      it 'returns nil for a meeting without entries and results' do
        new_meeting = create(:meeting)
        stat_without_entries = MeetingStatCalculator.new(new_meeting)
        expect(stat_without_entries.get_teams).to be_empty
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'entry-based methods' do
    describe '#get_entered_teams_count' do
      it 'returns a number > 0 for a meeting with entries' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        expect(stat_with_entries.get_entered_teams_count).to be > 0
      end
      it 'returns 0 for meeting without entries' do
        stat_without_entries = MeetingStatCalculator.new(meet_without_entries)
        expect(stat_without_entries.get_entered_teams_count).to eq(0)
      end
    end

    describe '#get_entries_count' do
      it 'returns a number > 0 for meeting with entries' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        expect(stat_with_entries.get_entries_count).to be > 0
        expect(stat_with_entries.get_entries_count(:is_male)).to be > 0
        expect(stat_with_entries.get_entries_count(:is_female)).to be > 0
      end
      it 'returns 0 for meeting without entries' do
        stat_without_entries = MeetingStatCalculator.new(meet_without_entries)
        expect(stat_without_entries.get_entries_count).to eq(0)
        expect(stat_without_entries.get_entries_count(:is_male)).to eq(0)
        expect(stat_without_entries.get_entries_count(:is_female)).to eq(0)
      end
      it 'returns the total entries number for males and females' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        expect(stat_with_entries.get_entries_count(:is_male) + stat_with_entries.get_entries_count(:is_female)).to eq(meet_with_entries.meeting_entries.count)
      end
    end

    describe '#get_team_entries_count' do
      it 'returns a number > 0 for a team with entries for the meeting' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        fix_team = meet_with_entries.teams.distinct.to_a.at((rand * meet_with_entries.teams.distinct.count).to_i)
        expect(stat_with_entries.get_team_entries_count(fix_team, :is_male) + stat_with_entries.get_team_entries_count(fix_team, :is_female)).to be > 0
      end
      it 'returns 0 for a team without entries for the meeting' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        new_team = create(:team)
        expect(stat_with_entries.get_team_entries_count(new_team)).to eq(0)
        expect(stat_with_entries.get_team_entries_count(new_team, :is_male)).to eq(0)
        expect(stat_with_entries.get_team_entries_count(new_team, :is_female)).to eq(0)
      end
      it 'returns 0 for meeting without entries' do
        stat_without_entries = MeetingStatCalculator.new(meet_without_entries)
        fix_team = meet_without_entries.teams.distinct.to_a.at((rand * meet_without_entries.teams.distinct.count).to_i)
        expect(stat_without_entries.get_team_entries_count(fix_team)).to eq(0)
        expect(stat_without_entries.get_team_entries_count(fix_team, :is_male)).to eq(0)
        expect(stat_without_entries.get_team_entries_count(fix_team, :is_female)).to eq(0)
      end
      it 'returns the total entries number for team male and female' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        fix_team = meet_with_entries.teams.distinct.to_a.at((rand * meet_with_entries.teams.distinct.count).to_i)
        expect(stat_with_entries.get_team_entries_count(fix_team, :is_male) + stat_with_entries.get_team_entries_count(fix_team, :is_female)).to eq(meet_with_entries.meeting_entries.for_team(fix_team).count)
      end
    end

    describe '#get_category_ent_swimmers_count' do
      # Should be 0 for meeting where the only swimmer of a certain category has been added withou entry (extremely rare)
      it 'returns a number > 0 for a category with entries for the meeting' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        fix_category = meet_with_entries.category_types.are_not_relays.distinct.to_a.at((rand * meet_with_entries.category_types.are_not_relays.distinct.count).to_i)
        while meet_with_entries.meeting_entries.for_category_type(fix_category).count == 0
          fix_category = meet_with_entries.category_types.are_not_relays.distinct.to_a.at((rand * meet_with_entries.category_types.are_not_relays.distinct.count).to_i)
        end
        expect(meet_with_entries.meeting_entries.for_category_type(fix_category).count).to be > 0
        expect(stat_with_entries.get_category_ent_swimmers_count(fix_category, :is_male) + stat_with_entries.get_category_ent_swimmers_count(fix_category, :is_female)).to be > 0
      end
      it 'returns 0 for a category without entries for the meeting' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        new_category = create(:category_type)
        expect(stat_with_entries.get_category_ent_swimmers_count(new_category)).to eq(0)
        expect(stat_with_entries.get_category_ent_swimmers_count(new_category, :is_male)).to eq(0)
        expect(stat_with_entries.get_category_ent_swimmers_count(new_category, :is_female)).to eq(0)
      end
      it 'returns 0 for meeting without entries' do
        stat_without_entries = MeetingStatCalculator.new(meet_without_entries)
        fix_category = meet_with_entries.category_types
                                        .are_not_relays.distinct
                                        .to_a.at((rand * meet_with_entries.category_types.are_not_relays.distinct.count).to_i)
        expect(stat_without_entries.get_category_ent_swimmers_count(fix_category)).to eq(0)
        expect(stat_without_entries.get_category_ent_swimmers_count(fix_category, :is_male)).to eq(0)
        expect(stat_without_entries.get_category_ent_swimmers_count(fix_category, :is_female)).to eq(0)
      end
      it 'returns the total entries number for category male and female' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        fix_category = meet_with_entries.category_types
                                        .are_not_relays.distinct
                                        .to_a.at((rand * meet_with_entries.category_types.are_not_relays.distinct.count).to_i)
        expect(stat_with_entries.get_category_ent_swimmers_count(fix_category, :is_male) + stat_with_entries.get_category_ent_swimmers_count(fix_category, :is_female)).to be <= meet_with_entries.meeting_entries.for_category_type(fix_category).count
      end
    end

    describe '#get_event_entries_count' do
      # Should be 0 for meeting where the only swimmer of a certain category has been added withou entry (extremely rare)
      it 'returns a number > 0 for an event with entries for the meeting' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        fix_event = meet_with_entries.event_types
                                     .are_not_relays.distinct
                                     .to_a.at((rand * meet_with_entries.event_types.are_not_relays.distinct.count).to_i)
        while meet_with_entries.meeting_entries.for_event_type(fix_event).count == 0
          fix_event = meet_with_entries.event_types
                                       .are_not_relays.distinct
                                       .to_a.at((rand * meet_with_entries.event_types.are_not_relays.distinct.count).to_i)
        end
        expect(stat_with_entries.get_event_entries_count(fix_event, :is_male) + stat_with_entries.get_event_entries_count(fix_event, :is_female)).to be > 0
      end
      it 'returns 0 for an event without entries for the meeting' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        new_event = EventType.find_by(code: '25FA')
        expect(stat_with_entries.get_event_entries_count(new_event)).to eq(0)
        expect(stat_with_entries.get_event_entries_count(new_event, :is_male)).to eq(0)
        expect(stat_with_entries.get_event_entries_count(new_event, :is_female)).to eq(0)
      end
      it 'returns 0 for meeting without entries' do
        stat_without_entries = MeetingStatCalculator.new(meet_without_entries)
        fix_event = meet_with_entries.event_types
                                     .are_not_relays.distinct
                                     .to_a.at((rand * meet_with_entries.event_types.are_not_relays.distinct.count).to_i)
        expect(stat_without_entries.get_event_entries_count(fix_event)).to eq(0)
        expect(stat_without_entries.get_event_entries_count(fix_event, :is_male)).to eq(0)
        expect(stat_without_entries.get_event_entries_count(fix_event, :is_female)).to eq(0)
      end
      it 'returns the total entries number for event male and female' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        fix_event = meet_with_entries.event_types
                                     .are_not_relays.distinct
                                     .to_a.at((rand * meet_with_entries.event_types.are_not_relays.distinct.count).to_i)
        expect(stat_with_entries.get_event_entries_count(fix_event, :is_male) + stat_with_entries.get_event_entries_count(fix_event, :is_female)).to eq(meet_with_entries.meeting_entries.for_event_type(fix_event).count)
      end
    end

    describe '#get_entered_swimmers_count' do
      it 'returns a number > 0 for meeting with entries' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        expect(stat_with_entries.get_entered_swimmers_count).to be > 0
        expect(stat_with_entries.get_entered_swimmers_count(:is_male)).to be > 0
        expect(stat_with_entries.get_entered_swimmers_count(:is_female)).to be > 0
      end
      it 'returns 0 for meeting without entries' do
        stat_without_entries = MeetingStatCalculator.new(meet_without_entries)
        expect(stat_without_entries.get_entered_swimmers_count).to eq(0)
        expect(stat_without_entries.get_entered_swimmers_count(:is_male)).to eq(0)
        expect(stat_without_entries.get_entered_swimmers_count(:is_female)).to eq(0)
      end
      it 'returns the total entered swimmers number for males and females' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        expect(
          stat_with_entries.get_entered_swimmers_count(:is_male) +
          stat_with_entries.get_entered_swimmers_count(:is_female)
        ).to be <= meet_with_entries.meeting_entries.count
      end
    end

    describe '#get_team_entered_swimmers_count' do
      it 'returns a number > 0 for a team with entries for the meeting' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        fix_team = meet_with_entries.teams
                                    .distinct
                                    .to_a.at((rand * meet_with_entries.teams.distinct.count).to_i)
        expect(stat_with_entries.get_team_entered_swimmers_count(fix_team, :is_male) + stat_with_entries.get_team_entered_swimmers_count(fix_team, :is_female)).to be > 0
      end
      it 'returns 0 for a team without entries for the meeting' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        new_team = create(:team)
        expect(stat_with_entries.get_team_entered_swimmers_count(new_team)).to eq(0)
        expect(stat_with_entries.get_team_entered_swimmers_count(new_team, :is_male)).to eq(0)
        expect(stat_with_entries.get_team_entered_swimmers_count(new_team, :is_female)).to eq(0)
      end
      it 'returns 0 for meeting without entries' do
        stat_without_entries = MeetingStatCalculator.new(meet_without_entries)
        fix_team = meet_without_entries.teams.distinct.to_a.at((rand * meet_without_entries.teams.distinct.count).to_i)
        expect(stat_without_entries.get_team_entered_swimmers_count(fix_team)).to eq(0)
        expect(stat_without_entries.get_team_entered_swimmers_count(fix_team, :is_male)).to eq(0)
        expect(stat_without_entries.get_team_entered_swimmers_count(fix_team, :is_female)).to eq(0)
      end
      it 'returns the total entered swimmers number for team male and female' do
        stat_with_entries = MeetingStatCalculator.new(meet_with_entries)
        fix_team = meet_with_entries.teams.distinct.to_a.at((rand * meet_with_entries.teams.distinct.count).to_i)
        expect(stat_with_entries.get_team_entered_swimmers_count(fix_team, :is_male) + stat_with_entries.get_team_entered_swimmers_count(fix_team, :is_female)).to be <= meet_with_entries.meeting_entries.for_team(fix_team).count
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'result-based methods' do
    describe '#get_teams_count' do
      it 'returns a number > 0 for a meeting with results' do
        expect(subject.get_teams_count).to be > 0
      end
      it 'returns 0 for meeting without entries' do
        stat_without_results = MeetingStatCalculator.new(create(:meeting))
        expect(stat_without_results.get_teams_count).to eq(0)
      end
    end

    describe '#get_results_count' do
      it 'returns a number > 0 for meeting with results' do
        expect(subject.get_results_count).to be > 0
        expect(subject.get_results_count(:is_male)).to be > 0
        expect(subject.get_results_count(:is_female)).to be > 0
      end
      it 'returns 0 for meeting without entries' do
        stat_without_results = MeetingStatCalculator.new(create(:meeting))
        expect(stat_without_results.get_results_count).to eq(0)
        expect(stat_without_results.get_results_count(:is_male)).to eq(0)
        expect(stat_without_results.get_results_count(:is_female)).to eq(0)
      end
      it 'returns the total swimmers number for males and females' do
        expect(subject.get_results_count(:is_male) + subject.get_results_count(:is_female)).to eq(meeting.meeting_individual_results.count)
      end
    end

    describe '#get_team_results_count' do
      it 'returns a number > 0 for a team with results for the meeting' do
        fix_team = meeting.teams.distinct
                          .to_a.at((rand * meeting.teams.distinct.count).to_i)
        expect(subject.get_team_results_count(fix_team, :is_male) + subject.get_team_results_count(fix_team, :is_female)).to be > 0
      end
      it 'returns 0 for a team without results for the meeting' do
        new_team = create(:team)
        expect(subject.get_team_results_count(new_team)).to eq(0)
        expect(subject.get_team_results_count(new_team, :is_male)).to eq(0)
        expect(subject.get_team_results_count(new_team, :is_female)).to eq(0)
      end
      it 'returns the total results number for team male and female' do
        fix_team = meeting.teams.distinct
                          .to_a.at((rand * meeting.teams.distinct.count).to_i)
        expect(subject.get_team_results_count(fix_team, :is_male) + subject.get_team_results_count(fix_team, :is_female)).to eq(meeting.meeting_individual_results.for_team(fix_team).count)
      end
    end

    describe '#get_category_swimmers_count' do
      it 'returns a number > 0 for a category with results for the meeting' do
        fix_category = meeting.category_types
                              .are_not_relays.distinct
                              .to_a.at((rand * meeting.category_types.are_not_relays.distinct.count).to_i)
        expect(subject.get_category_swimmers_count(fix_category, :is_male) + subject.get_category_swimmers_count(fix_category, :is_female)).to be > 0
      end
      it 'returns 0 for a team without results for the meeting' do
        new_category = create(:category_type)
        expect(subject.get_category_swimmers_count(new_category)).to eq(0)
        expect(subject.get_category_swimmers_count(new_category, :is_male)).to eq(0)
        expect(subject.get_category_swimmers_count(new_category, :is_female)).to eq(0)
      end
      it 'returns the total results number for category male and female' do
        fix_category = meeting.category_types
                              .are_not_relays.distinct
                              .to_a.at((rand * meeting.category_types.are_not_relays.distinct.count).to_i)
        expect(subject.get_category_swimmers_count(fix_category, :is_male) + subject.get_category_swimmers_count(fix_category, :is_female)).to be <= meeting.meeting_individual_results.for_category_type(fix_category).count
      end
    end

    describe '#get_event_results_count' do
      it 'returns a number > 0 for an event with results for the meeting' do
        fix_event = meeting.event_types
                           .are_not_relays.distinct
                           .to_a.at((rand * meeting.event_types.are_not_relays.distinct.count).to_i)
        expect(subject.get_event_results_count(fix_event, :is_male) + subject.get_event_results_count(fix_event, :is_female)).to be > 0
      end
      it 'returns 0 for a team without results for the meeting' do
        new_event = EventType.find_by(code: '25FA')
        expect(subject.get_event_results_count(new_event)).to eq(0)
        expect(subject.get_event_results_count(new_event, :is_male)).to eq(0)
        expect(subject.get_event_results_count(new_event, :is_female)).to eq(0)
      end
      it 'returns the total results number for event male and female' do
        fix_event = meeting.event_types
                           .are_not_relays.distinct
                           .to_a.at((rand * meeting.event_types.are_not_relays.distinct.count).to_i)
        expect(subject.get_event_results_count(fix_event, :is_male) + subject.get_event_results_count(fix_event, :is_female)).to eq(meeting.meeting_individual_results.for_event_type(fix_event).count)
      end
    end

    describe '#get_swimmers_count' do
      it 'returns a number > 0 for meeting with results' do
        expect(subject.get_swimmers_count).to be > 0
        expect(subject.get_swimmers_count(:is_male)).to be > 0
        expect(subject.get_swimmers_count(:is_female)).to be > 0
      end
      it 'returns 0 for meeting without results' do
        stat_without_results = MeetingStatCalculator.new(create(:meeting))
        expect(stat_without_results.get_swimmers_count).to eq(0)
        expect(stat_without_results.get_swimmers_count(:is_male)).to eq(0)
        expect(stat_without_results.get_swimmers_count(:is_female)).to eq(0)
      end
      it 'returns the total swimmers number for males and females' do
        expect(subject.get_swimmers_count(:is_male) + subject.get_swimmers_count(:is_female)).to be <= meeting.meeting_individual_results.count
      end
    end

    describe '#get_team_swimmers_count' do
      it 'returns a number > 0 for a team with results for the meeting' do
        fix_team = meeting.teams.distinct
                          .to_a.at((rand * meeting.teams.distinct.count).to_i)
        expect(subject.get_team_swimmers_count(fix_team, :is_male) + subject.get_team_swimmers_count(fix_team, :is_female)).to be > 0
      end
      it 'returns 0 for a team without results for the meeting' do
        new_team = create(:team)
        expect(subject.get_team_swimmers_count(new_team)).to eq(0)
        expect(subject.get_team_swimmers_count(new_team, :is_male)).to eq(0)
        expect(subject.get_team_swimmers_count(new_team, :is_female)).to eq(0)
      end
      it 'returns the total swimmers number for team male and female' do
        fix_team = meeting.teams.distinct
                          .to_a.at((rand * meeting.teams.distinct.count).to_i)
        expect(subject.get_team_swimmers_count(fix_team, :is_male) + subject.get_team_swimmers_count(fix_team, :is_female)).to be <= meeting.meeting_individual_results.for_team(fix_team).count
      end
    end

    describe '#get_disqualifieds_count' do
      it 'returns a number >= 0 for meeting with results' do
        expect(subject.get_disqualifieds_count).to be >= 0
        expect(subject.get_disqualifieds_count(:is_male)).to be >= 0
        expect(subject.get_disqualifieds_count(:is_female)).to be >= 0
      end
      it 'returns 0 for meeting without entries' do
        stat_without_results = MeetingStatCalculator.new(create(:meeting))
        expect(stat_without_results.get_disqualifieds_count).to eq(0)
        expect(stat_without_results.get_disqualifieds_count(:is_male)).to eq(0)
        expect(stat_without_results.get_disqualifieds_count(:is_female)).to eq(0)
      end
      it 'returns the total swimmers number for males and females' do
        expect(subject.get_disqualifieds_count(:is_male) + subject.get_disqualifieds_count(:is_female)).to eq(meeting.meeting_individual_results.is_disqualified.count)
      end
    end

    describe '#get_team_disqualifieds_count' do
      it 'returns a number > 0 for a team with disqualifieds for the meeting' do
        fix_team = meeting.teams.distinct
                          .to_a.at((rand * meeting.teams.distinct.count).to_i)
        fix_result = meeting.meeting_individual_results.for_team(fix_team).first
        fix_result.is_disqualified = true
        fix_result.save
        expect(meeting.meeting_individual_results.is_disqualified.for_team(fix_team).count).to be > 0
        expect(subject.get_team_results_count(fix_team, :is_male) + subject.get_team_results_count(fix_team, :is_female)).to be > 0
      end
      it 'returns 0 for a team without disqualifieds for the meeting' do
        new_team = create(:team)
        expect(subject.get_team_disqualifieds_count(new_team)).to eq(0)
        expect(subject.get_team_disqualifieds_count(new_team, :is_male)).to eq(0)
        expect(subject.get_team_disqualifieds_count(new_team, :is_female)).to eq(0)
      end
      it 'returns the total disqualifieds number for team male and female' do
        fix_team = meeting.teams.distinct
                          .to_a.at((rand * meeting.teams.distinct.count).to_i)
        expect(subject.get_team_disqualifieds_count(fix_team, :is_male) + subject.get_team_disqualifieds_count(fix_team, :is_female)).to eq(meeting.meeting_individual_results.is_disqualified.for_team(fix_team).count)
      end
    end

    describe '#get_team_best_standard' do
      it 'returns a number > 0 for a team with results with standard points for the meeting' do
        stat_with_standard_points = MeetingStatCalculator.new(meet_with_standard_points)
        fix_team = meet_with_standard_points.teams
                                            .distinct
                                            .to_a.at((rand * meet_with_standard_points.teams.distinct.count).to_i)
        if meet_with_standard_points.meeting_individual_results.for_team(fix_team).has_points.count > 0
          expect(stat_with_standard_points.get_team_best_standard(fix_team, :is_male) + stat_with_standard_points.get_team_best_standard(fix_team, :is_female)).to be > 0
        else
          # Avoid the fucking teams with U25 only
          expect(stat_with_standard_points.get_team_best_standard(fix_team, :is_male) + stat_with_standard_points.get_team_best_standard(fix_team, :is_female)).to eq(0)
        end
      end
      it 'returns 0 for a team without results with standard points for the meeting' do
        new_team = create(:team)
        expect(subject.get_team_best_standard(new_team)).to eq(0)
        expect(subject.get_team_best_standard(new_team, :is_male)).to eq(0)
        expect(subject.get_team_best_standard(new_team, :is_female)).to eq(0)
      end
      it 'returns the highest standard point for the team for the meeting' do
        fix_team = meeting.teams.distinct
                          .to_a.at((rand * meeting.teams.distinct.count).to_i)
        fix_result = meeting.meeting_individual_results.for_team(fix_team).first
        fix_result.standard_points = ((rand * 1000).to_i + 2000)
        fix_result.save
        if fix_result.gender_type.code == 'F'
          expect(subject.get_team_best_standard(fix_team, :is_female)).to eq(fix_result.standard_points)
        elsif fix_result.gender_type.code == 'M'
          expect(subject.get_team_best_standard(fix_team, :is_male)).to eq(fix_result.standard_points)
        end
      end
    end

    describe '#get_team_worst_standard' do
      it 'returns a number > 0 for a team with results with standard points for the meeting' do
        stat_with_standard_points = MeetingStatCalculator.new(meet_with_standard_points)
        fix_team = meet_with_standard_points.teams.distinct
                                            .to_a.at((rand * meet_with_standard_points.teams.distinct.count).to_i)
        expect(stat_with_standard_points.get_team_worst_standard(fix_team, :is_male) + stat_with_standard_points.get_team_worst_standard(fix_team, :is_female)).to be > 0
      end
      it 'returns 0 for a team without results with standard points for the meeting' do
        new_team = create(:team)
        expect(subject.get_team_worst_standard(new_team)).to eq(0)
        expect(subject.get_team_worst_standard(new_team, :is_male)).to eq(0)
        expect(subject.get_team_worst_standard(new_team, :is_female)).to eq(0)
      end
      it 'returns the lowest standard point for the team for the meeting' do
        fix_team = meeting.teams.distinct
                          .to_a.at((rand * meeting.teams.distinct.count).to_i)
        fix_result = meeting.meeting_individual_results.for_team(fix_team).first
        fix_result.standard_points = ((rand * 200).to_i + 10)
        fix_result.save
        if fix_result.gender_type.code == 'F'
          expect(subject.get_team_worst_standard(fix_team, :is_female)).to eq(fix_result.standard_points)
        elsif fix_result.gender_type.code == 'M'
          expect(subject.get_team_worst_standard(fix_team, :is_male)).to eq(fix_result.standard_points)
        end
      end
    end

    describe '#get_average' do
      it 'returns a number > 0 for a meeting with results with standard points' do
        stat_with_standard_points = MeetingStatCalculator.new(meet_with_standard_points)
        expect(stat_with_standard_points.get_average).to be > 0
        expect(stat_with_standard_points.get_average(:is_male)).to be > 0
        expect(stat_with_standard_points.get_average(:is_female)).to be > 0
      end
      it 'returns 0 for a meeting without results' do
        stat_without_results = MeetingStatCalculator.new(create(:meeting))
        expect(stat_without_results.get_average).to eq(0)
        expect(stat_without_results.get_average(:is_male)).to eq(0)
        expect(stat_without_results.get_average(:is_female)).to eq(0)
      end
      it 'returns a value smaller than best and bigger than worst' do
        stat_with_standard_points = MeetingStatCalculator.new(meet_with_standard_points)
        ave_male = stat_with_standard_points.get_average(:is_male)
        ave_female = stat_with_standard_points.get_average(:is_female)
        expect(ave_male).to be <= stat_with_standard_points.get_best_standard_scores(:is_male).first.standard_points
        expect(ave_male).to be >= stat_with_standard_points.get_worst_standard_scores(:is_male).first.standard_points
        expect(ave_female).to be <= stat_with_standard_points.get_best_standard_scores(:is_female).first.standard_points
        expect(ave_female).to be >= stat_with_standard_points.get_worst_standard_scores(:is_female).first.standard_points
      end
    end

    describe '#get_team_average' do
      it 'returns a number > 0 for a team with results with standard points for the meeting' do
        stat_with_standard_points = MeetingStatCalculator.new(meet_with_standard_points)
        fix_team = meet_with_standard_points.teams.distinct
                                            .to_a.at((rand * meet_with_standard_points.teams.distinct.count).to_i)
        expect(stat_with_standard_points.get_team_average(fix_team, :is_male) + stat_with_standard_points.get_team_average(fix_team, :is_female)).to be > 0
      end
      it 'returns 0 for a team without results with standard points for the meeting' do
        new_team = create(:team)
        expect(subject.get_team_average(new_team)).to eq(0)
        expect(subject.get_team_average(new_team, :is_male)).to eq(0)
        expect(subject.get_team_average(new_team, :is_female)).to eq(0)
      end
      it 'returns a value smaller than best and bigger than worst' do
        stat_with_standard_points = MeetingStatCalculator.new(meet_with_standard_points)
        fix_team = meet_with_standard_points.teams.distinct
                                            .to_a.at((rand * meet_with_standard_points.teams.distinct.count).to_i)
        ave_male = stat_with_standard_points.get_team_average(fix_team, :is_male)
        ave_female = stat_with_standard_points.get_team_average(fix_team, :is_female)
        expect(ave_male).to be <= stat_with_standard_points.get_team_best_standard(fix_team, :is_male)
        expect(ave_male).to be >= stat_with_standard_points.get_team_worst_standard(fix_team, :is_male)
        expect(ave_female).to be <= stat_with_standard_points.get_team_best_standard(fix_team, :is_female)
        expect(ave_female).to be >= stat_with_standard_points.get_team_worst_standard(fix_team, :is_female)
      end
    end

    describe '#get_relays_average' do
      it 'returns a number > 0 for a meeting with results with standard points' do
        stat_with_standard_relays = MeetingStatCalculator.new(meet_with_std_relays)
        expect(stat_with_standard_relays.get_relays_average).to be > 0
      end
      it 'returns 0 for a meeting without results' do
        stat_without_results = MeetingStatCalculator.new(create(:meeting))
        expect(stat_without_results.get_relays_average).to eq(0)
      end
      it 'returns 0 for a meeting without relays' do
        stat_without_relays = MeetingStatCalculator.new(meet_without_relays)
        expect(stat_without_relays.get_relays_average).to eq(0)
      end
    end

    describe '#get_team_medals' do
      it 'returns a number >= 0 for a team with results for the meeting' do
        fix_team = meeting.teams.distinct
                          .to_a.at((rand * meeting.teams.distinct.count).to_i)
        expect(subject.get_team_medals(fix_team, :is_male, (rand * 2 + 1).to_i) + subject.get_team_medals(fix_team, :is_female, (rand * 2 + 1).to_i)).to be >= 0
      end
      it 'returns 0 for a team without results for the meeting' do
        new_team = create(:team)
        expect(subject.get_team_medals(new_team)).to eq(0)
        expect(subject.get_team_medals(new_team, :is_male)).to eq(0)
        expect(subject.get_team_medals(new_team, :is_female)).to eq(0)
        expect(subject.get_team_medals(new_team, :is_male, 1)).to eq(0)
        expect(subject.get_team_medals(new_team, :is_female, 1)).to eq(0)
        expect(subject.get_team_medals(new_team, :is_male, 2)).to eq(0)
        expect(subject.get_team_medals(new_team, :is_female, 2)).to eq(0)
        expect(subject.get_team_medals(new_team, :is_male, 3)).to eq(0)
        expect(subject.get_team_medals(new_team, :is_female, 3)).to eq(0)
      end
      it 'returns more than 0 for Ober Ferrari in CSI meetings' do
        fix_team = Team.find(1)
        stat_csi = MeetingStatCalculator.new(csi_meeting)
        expect(stat_csi.get_team_medals(fix_team, :is_male, 1) + stat_csi.get_team_medals(fix_team, :is_male, 2) + stat_csi.get_team_medals(fix_team, :is_male, 3)).to be > 0
        expect(stat_csi.get_team_medals(fix_team, :is_female, 1) + stat_csi.get_team_medals(fix_team, :is_female, 2) + stat_csi.get_team_medals(fix_team, :is_female, 3)).to be > 0
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#get_oldest_swimmers' do
    it 'returns only male swimmers' do
      subject.get_oldest_swimmers.each do |item|
        expect(item.is_male).to be true
      end
    end
    it 'returns only female swimmers' do
      subject.get_oldest_swimmers(:is_female).each do |item|
        expect(item.is_female).to be true
      end
    end
    it 'returns a list sorted by swimmer year_of_birth' do
      current_item_year = subject.get_oldest_swimmers.first.year_of_birth
      subject.get_oldest_swimmers.each do |item|
        expect(item.year_of_birth).to be >= current_item_year
        current_item_year = item.year_of_birth
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#get_best_standard_scores' do
    it 'returns only not disqualified results' do
      subject.get_best_standard_scores.each do |item|
        expect(item.is_disqualified).to be false
      end
      subject.get_best_standard_scores(:is_female).each do |item|
        expect(item.is_disqualified).to be false
      end
    end
    it 'returns a list sorted by standard points descending' do
      current_item_score = subject.get_best_standard_scores.first.standard_points if subject.get_best_standard_scores.first
      subject.get_best_standard_scores.each do |item|
        expect(item.standard_points).to be <= current_item_score
        current_item_score = item.standard_points
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#get_worst_standard_scores' do
    it 'returns only not disqualified results' do
      subject.get_worst_standard_scores.each do |item|
        expect(item.is_disqualified).to be false
      end
      subject.get_worst_standard_scores(:is_female).each do |item|
        expect(item.is_disqualified).to be false
      end
    end
    it 'returns a list sorted by standard points' do
      current_item_score = subject.get_worst_standard_scores.first.standard_points if subject.get_worst_standard_scores.first
      subject.get_worst_standard_scores.each do |item|
        expect(item.standard_points).to be >= current_item_score
        current_item_score = item.standard_points
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Assumes each single values are corrects and already spec'd
  # before for each single calculation method
  describe '#calculate_teams' do
    it 'responds to #calculate_teams' do
      expect(subject).to respond_to(:calculate_teams)
    end
    it 'returns an array' do
      expect(subject.calculate_teams).to be_a_kind_of(Array)
    end
    it 'returns an array with at least one team' do
      expect(subject.calculate_teams.count).to be > 0
    end
    it 'returns an array with the team count number of elements' do
      expect(subject.calculate_teams(false).count).to eq(subject.calculate(3, 1, 1, false, false, false, false).get_teams_count)
    end
    it 'returns an array with at least the entered team count number of elements if entries considered' do
      expect(subject.calculate_teams.count).to be >= subject.calculate(3, 1, 1, true, false, false, false).get_ent_teams_count
    end
    it 'returns an array of MeetingStatDAO::TeamMeetingStatDAO' do
      expect(subject.calculate_teams).to all(be_an_instance_of(MeetingStatDAO::TeamMeetingStatDAO))
    end
    it 'returns stats data for each team considered' do
      subject.calculate_teams.each do |team_stat|
        # Try to find out a fucking random failure, that, of corse, will no more happen, huncle dog!
        puts "#{subject.meeting.id} #{subject.meeting.get_full_name} - #{team_stat.team.get_full_name}" if (team_stat.get_results_count + team_stat.get_entries_count + team_stat.get_disqualifieds_count + team_stat.relay_results) == 0
        expect(team_stat.get_results_count + team_stat.get_entries_count + team_stat.get_disqualifieds_count + team_stat.relay_results).to be > 0
        expect(team_stat.get_swimmers_count + team_stat.get_ent_swimmers_count).to be > 0
      end
    end
    it 'returns stats data for CSI Nuoto Ober Ferrari in CSI meetings' do
      fix_team = Team.find(1)
      stat_csi = MeetingStatCalculator.new(csi_meeting)
      team_stats = stat_csi.calculate_teams
      expect(team_stats.size).to be > 0
      expect(team_stats.rindex { |ts| ts.team == fix_team }).not_to be nil
    end
    it 'ignores entries stats if not requested' do
      subject.calculate_teams(false).each do |team_stat|
        expect(team_stat.get_entries_count).to eq(0)
        expect(team_stat.get_ent_swimmers_count).to eq(0)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Assumes each single values are corrects and already spec'd
  # before for each single calculation method
  describe '#calculate_categories' do
    it 'responds to #calculate_categories' do
      expect(subject).to respond_to(:calculate_categories)
    end
    it 'returns an array' do
      expect(subject.calculate_categories).to be_a_kind_of(Array)
    end
    it 'returns an array with at least one category' do
      expect(subject.calculate_categories.count).to be > 0
    end
    it 'returns an array with the category count number of elements' do
      expect(subject.calculate_categories.count).to eq(meeting.category_types.are_not_relays.distinct.count)
    end
    it 'returns an array of MeetingStatDAO::CategoryMeetingStatDAO' do
      expect(subject.calculate_categories).to all(be_an_instance_of(MeetingStatDAO::CategoryMeetingStatDAO))
    end
    it 'returns stats data for each category considered' do
      subject.calculate_categories.each do |category_stat|
        expect(category_stat.get_ent_swimmers_count + category_stat.get_swimmers_count).to be > 0
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Assumes each single values are corrects and already spec'd
  # before for each single calculation method
  describe '#calculate_events' do
    it 'responds to #calculate_events' do
      expect(subject).to respond_to(:calculate_events)
    end
    it 'returns an array' do
      expect(subject.calculate_events).to be_a_kind_of(Array)
    end
    it 'returns an array with at least one event' do
      expect(subject.calculate_events.count).to be > 0
    end
    it 'returns an array with the event count number of elements' do
      expect(subject.calculate_events.count).to eq(meeting.event_types.are_not_relays.distinct.count)
    end
    it 'returns an array of MeetingStatDAO::EventMeetingStatDAO' do
      expect(subject.calculate_events).to all(be_an_instance_of(MeetingStatDAO::EventMeetingStatDAO))
    end
    it 'returns stats data for each event considered' do
      subject.calculate_events.each do |event_stat|
        expect(event_stat.get_entries_count + event_stat.get_results_count).to be > 0
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Assumes values are corrects and already spec'd
  # before for each single calculation method
  describe '#calculate' do
    it 'responds to #calculate' do
      expect(subject).to respond_to(:calculate)
    end
    it 'returns a MeetingStatDAO' do
      expect(subject.calculate).to be_an_instance_of(MeetingStatDAO)
    end
    it 'returns a MeetingStatDAO with teams count for a meeting with results' do
      expect(subject.has_results?).to be true
      expect(subject.get_teams_count).to be > 0
      expect(subject.get_results_count).to be > 0
      ms = subject.calculate(3, 1, 1, false, false, false, false)
      expect(ms.teams_count).to be > 0
      expect(ms.get_results_count).to eq(subject.get_results_count(:is_male) + subject.get_results_count(:is_female))
    end
    it 'returns a MeetingStatDAO with congruent data between general and teams' do
      expect(subject.has_results?).to be true
      ms = subject.calculate(0, 0, 0, false, true, false, false, false, false)
      expect(ms.categories.count).to eq(0)
      expect(ms.events.count).to eq(0)
      expect(ms.teams_count).to be > 0
      expect(ms.teams_count).to eq(ms.teams.count)
      males = 0
      females = 0
      s_males = 0
      s_females = 0
      relays = 0
      ms.teams.each do |team_stat|
        males += team_stat.male_results
        females += team_stat.female_results
        relays += team_stat.relay_results
        s_males += team_stat.male_swimmers
        s_females += team_stat.female_swimmers
      end
      expect(ms.results_male_count).to eq(males)
      expect(ms.results_female_count).to eq(females)
      expect(ms.swimmers_male_count).to eq(s_males)
      expect(ms.swimmers_female_count).to eq(s_females)
      expect(ms.results_relay_count).to eq(relays)
    end
    it 'returns a MeetingStatDAO with congruent data between general and categories' do
      expect(subject.has_results?).to be true
      ms = subject.calculate(0, 0, 0, false, false, true, false, false, false)
      expect(ms.teams.count).to eq(0)
      expect(ms.events.count).to eq(0)
      s_males = 0
      s_females = 0
      ms.categories.each do |category_stat|
        s_males += category_stat.male_swimmers
        s_females += category_stat.female_swimmers
      end
      expect(ms.swimmers_male_count).to eq(s_males)
      expect(ms.swimmers_female_count).to eq(s_females)
    end
    it 'returns a MeetingStatDAO with congruent data between general and events' do
      expect(subject.has_results?).to be true
      ms = subject.calculate(0, 0, 0, false, false, false, true, false, false)
      expect(ms.teams.count).to eq(0)
      expect(ms.categories.count).to eq(0)
      males = 0
      females = 0
      ms.events.each do |event_stat|
        males += event_stat.male_results
        females += event_stat.female_results
      end
      expect(ms.results_male_count).to eq(males)
      expect(ms.results_female_count).to eq(females)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'not a valid instance' do
    it 'raises an exception for wrong meeting parameter' do
      expect { MeetingStatCalculator.new }.to raise_error(ArgumentError)
      expect { MeetingStatCalculator.new('Wrong parameter') }.to raise_error(ArgumentError)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
