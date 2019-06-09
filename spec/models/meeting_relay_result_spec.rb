# frozen_string_literal: true

require 'rails_helper'

describe MeetingRelayResult, type: :model do
  it_behaves_like 'TimingGettable'
  #-- -------------------------------------------------------------------------
  #++

  context '[Standard Factory]' do
    subject { create(:meeting_relay_result) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    it 'has a valid Team istance' do
      expect(subject.team).to be_valid
    end
    it 'has a valid MeetingProgram istance' do
      expect(subject.meeting_program).to be_valid
    end
    it 'has a valid TeamAffiliation istance' do
      expect(subject.team_affiliation).to be_valid
    end

    it 'refers to a relay result' do
      expect(subject.meeting_program.event_type.is_a_relay).to be true
    end

    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:meeting_program, :team, :team_affiliation, :entry_time_type])
    it_behaves_like('(it has_one of these required models)', [:meeting_event, :meeting_session, :meeting, :season, :pool_type, :season_type, :event_type, :category_type, :gender_type])
  end
  #-- -------------------------------------------------------------------------
  #++

  # TODO: add test context for scopes (not for sorting scopes)

  # TODO: same sections as MeetingIndividualResult spec
end
