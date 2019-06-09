# frozen_string_literal: true

require 'rails_helper'

describe Badge, type: :model do
  describe '[a non-valid instance]' do
    it_behaves_like('(missing required values)', [:number])
  end
  #-- -------------------------------------------------------------------------
  #++

  context '[a well formed instance]' do
    subject { create(:badge) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:team, :season, :swimmer, :team_affiliation, :category_type, :entry_time_type])

    # Additional instance helpers:
    [:season_type, :gender_type, :team_managers, :meeting_individual_results, :passages, :meetings].each do |method|
      it "responds to #{method}" do
        expect(subject).to respond_to(method)
      end
    end

    # Filtering scopes:
    it_behaves_like('(the existance of a class method)', [:sort_by_user, :sort_by_season, :sort_by_team, :sort_by_swimmer, :sort_by_category_type, :for_category_type, :for_gender_type, :for_season, :for_team, :for_swimmer, :for_final_rank, :for_season_type, :for_year, :for_team_affiliation])

    context '[general methods]' do
      it_behaves_like('(the existance of a method returning non-empty strings)', [:get_full_name, :get_verbose_name, :get_entry_time_type_code])
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe 'self.for_season' do
    context 'for a Season with existing Badges,' do
      it 'returns a list of Badges' do
        season = Season.find(rand(1..15))
        expect(subject.class.for_season(season)).to all be_a(Badge)
      end
    end
    context 'for a Season with NO Badges,' do
      it 'returns an empty list' do
        season = create(:season)
        expect(subject.class.for_season(season)).to be_empty
      end
    end
  end

  describe 'self.for_team' do
    context 'for a Team with existing Badges,' do
      it 'returns a list of Badges' do
        team = Team.find(rand(1..10))
        expect(subject.class.for_team(team)).to all be_a(Badge)
      end
    end
    context 'for a Team with NO Badges,' do
      it 'returns an empty list' do
        team = create(:team)
        expect(subject.class.for_team(team)).to be_empty
      end
    end
  end

  describe 'self.for_swimmer' do
    context 'for a Swimmer with existing Badges,' do
      it 'returns a list of Badges' do
        swimmer = Swimmer.find(rand(1..10))
        expect(subject.class.for_swimmer(swimmer)).to all be_a(Badge)
      end
    end
    context 'for a Swimmer with NO Badges,' do
      it 'returns an empty list' do
        swimmer = create(:swimmer)
        expect(subject.class.for_swimmer(swimmer)).to be_empty
      end
    end
  end

  describe 'self.for_team_affiliation' do
    context 'for a TeamAffiliation with existing Badges,' do
      it 'returns a list of Badges' do
        ta = TeamAffiliation.find(rand(1..10))
        expect(subject.class.for_team_affiliation(ta)).to all be_a(Badge)
      end
    end
    context 'for a TeamAffiliation with NO Badges,' do
      it 'returns an empty list' do
        ta = create(:team_affiliation)
        expect(subject.class.for_team_affiliation(ta)).to be_empty
      end
    end
  end
  # ---------------------------------------------------------------------------
  #++

  describe '#has_ironmaster?' do
    it 'returns a boolean' do
      expect(subject.has_ironmaster?).to be(true).or(be(false))
    end
    it 'returns false for an empty badge' do
      badge = create(:badge)
      expect(badge.has_ironmaster?).to be(false)
    end
    it 'returns false for Leega 152' do
      leega = Swimmer.find(23)
      ironbadge = leega.badges.where(season: 152).first
      expect(ironbadge.has_ironmaster?).to be(true)
    end
  end
  # ---------------------------------------------------------------------------
  #++
end
