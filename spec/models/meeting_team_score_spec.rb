# frozen_string_literal: true

require 'rails_helper'

describe MeetingTeamScore, type: :model do
  # TODO
  # describe "[a non-valid instance]" do
  # it_behaves_like( "(missing required values)", [ :number ])
  # end
  #-- -------------------------------------------------------------------------
  #++

  # This is mainly used to test the factory and its relationships:
  context '[Standard Factory]' do
    subject { create(:meeting_team_score) }
    it_behaves_like('a valid instance having a valid Season, Meeting and Team (+Affiliation)')
  end

  context "[Factory 'with_relay_results']" do
    subject { create(:meeting_team_score_with_relay_results) }
    it_behaves_like('a valid instance having a valid Season, Meeting and Team (+Affiliation)')

    it 'creates at least 1 MeetingSession' do
      expect(subject.meeting.meeting_sessions.count).to be >= 1
    end
    it 'creates only valid MeetingSessions' do
      subject.meeting.meeting_sessions.each do |meeting_session|
        expect(meeting_session).to be_valid
      end
    end

    it 'creates at least 1 MeetingEvent' do
      expect(subject.meeting.meeting_events.count).to be >= 1
    end
    it 'creates only valid MeetingEvents' do
      subject.meeting.meeting_events.each do |meeting_event|
        expect(meeting_event).to be_valid
      end
    end

    it 'creates at least 1 DataImportMeetingProgram' do
      di_mprgs = MeetingProgram
                 .joins(:meeting)
                 .includes(:meeting)
                 .where('meetings.id = ?', subject.meeting_id)
      expect(di_mprgs.count).to be >= 1
    end
    it 'creates only valid DataImportMeetingPrograms' do
      di_mprgs = MeetingProgram
                 .joins(:meeting)
                 .includes(:meeting)
                 .where('meetings.id = ?', subject.meeting_id)
      di_mprgs.each do |di_mprg|
        expect(di_mprg).to be_valid
      end
    end

    it 'creates at least 1 DataImportMeetingRelayResult' do
      di_mprgs = MeetingRelayResult
                 .joins(:meeting)
                 .includes(:meeting)
                 .where('meetings.id = ?', subject.meeting_id)
      expect(di_mprgs.count).to be >= 1
    end
    it 'creates only valid DataImportMeetingRelayResult' do
      di_mprgs = MeetingRelayResult
                 .joins(:meeting)
                 .includes(:meeting)
                 .where('meetings.id = ?', subject.meeting_id)
      di_mprgs.each do |di_mprg|
        expect(di_mprg).to be_valid
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context '[defined scopes]' do
    let(:team_affiliation)    { create(:team_affiliation) }
    let(:team)                { team_affiliation.team }
    let(:season)              { team_affiliation.season }
    let(:meeting)             { create(:meeting, season: season) }
    let(:tot_created_rows)    { 3 }

    [:has_season_points, :for_team, :for_meeting].each do |method_sym|
      it "has a ##{method_sym} scope" do
        expect(MeetingTeamScore).to respond_to(method_sym)
      end
    end

    describe '#has_season_points' do
      before(:each) do
        create_list(
          :meeting_team_score, tot_created_rows,
          meeting: meeting,
          season_individual_points: (rand * 1000).to_i + 1,
          season_relay_points: (rand * 1000).to_i + 1,
          season_team_points: (rand * 1000).to_i + 1
        )
      end
      it 'returns a non empty list when there are rows satisfying the condition' do
        expect(MeetingTeamScore.has_season_points.where(meeting_id: meeting.id).count).to eq(tot_created_rows)
      end
      it 'returns a list of MeetingTeamScore rows' do
        expect(MeetingTeamScore.has_season_points.where(meeting_id: meeting.id)).to all be_instance_of(MeetingTeamScore)
      end
      it 'returns a list of rows with positive season points' do
        MeetingTeamScore.has_season_points.where(meeting_id: meeting.id).each do |row|
          expect(row.season_individual_points.to_i).to be >= 1
          expect(row.season_relay_points.to_i).to be >= 1
          expect(row.season_team_points.to_i).to be >= 1
        end
      end
    end

    describe '#for_team' do
      before(:each) do
        create_list(
          :meeting_team_score, tot_created_rows,
          team: team,
          season_individual_points: (rand * 1000).to_i + 1,
          season_relay_points: (rand * 1000).to_i + 1,
          season_team_points: (rand * 1000).to_i + 1
        )
      end
      it 'returns a non empty list when there are rows satisfying the condition' do
        expect(MeetingTeamScore.for_team(team).count).to eq(tot_created_rows)
      end
      it 'returns a list of MeetingTeamScore rows' do
        expect(MeetingTeamScore.for_team(team)).to all be_instance_of(MeetingTeamScore)
      end
    end

    describe '#for_meeting' do
      before(:each) do
        create_list(
          :meeting_team_score,      tot_created_rows,
          meeting: meeting,
          season_individual_points: (rand * 1000).to_i + 1,
          season_relay_points: (rand * 1000).to_i + 1,
          season_team_points: (rand * 1000).to_i + 1
        )
      end
      it 'returns a non empty list when there are rows satisfying the condition' do
        expect(MeetingTeamScore.for_meeting(meeting).count).to eq(tot_created_rows)
      end
      it 'returns a list of MeetingTeamScore rows' do
        expect(MeetingTeamScore.for_meeting(meeting)).to all be_instance_of(MeetingTeamScore)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
