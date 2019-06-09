# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SwimmerSeasonScore, type: :model do
  context '[a well formed instance]' do
    subject { create(:swimmer_season_score) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end

    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:badge, :event_type, :meeting_individual_result])

    context '[general methods]' do
      it_behaves_like('(the existance of a method returning non-empty strings)', [:get_swimmer_name, :get_team_name, :event_type_code, :category_type_code, :gender_type_code])
    end

    describe '#get_swimmer_name' do
      it 'returns a string that contains swimmer name' do
        expect(subject.get_swimmer_name).to include(subject.badge.swimmer.get_full_name)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#get_team_name' do
      it 'returns a string that contains team name' do
        expect(subject.get_team_name).to include(subject.badge.team.get_full_name)
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
end
