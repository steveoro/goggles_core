# frozen_string_literal: true

require 'rails_helper'

describe MeetingRelaySwimmer, type: :model do
  it_behaves_like 'SwimmerRelatable'
  it_behaves_like 'TimingGettable'
  #-- -------------------------------------------------------------------------
  #++

  context '[a well formed instance]' do
    subject { create(:meeting_relay_swimmer) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated relations:
    it_behaves_like('(belongs_to required models)', [
                      :stroke_type,
                      :meeting_relay_result,

                      :swimmer,
                      :badge,

                      :team # has_one .. through
                    ])
  end
  #-- -------------------------------------------------------------------------
  #++
end
