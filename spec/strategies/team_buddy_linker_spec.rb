# frozen_string_literal: true

require 'rails_helper'
require 'team_buddy_linker'

describe TeamBuddyLinker, type: :strategy do
  before :each do
    team     = create(:team)
    badges   = create_list(:badge, 3, team: team)
    swimmers = badges.map(&:swimmer)
    @user, @user2, @user3 = create_list(:user, 3)
    @user.set_associated_swimmer(swimmers[0])
    @user2.set_associated_swimmer(swimmers[1])
    @user3.set_associated_swimmer(swimmers[2])
  end

  subject { TeamBuddyLinker.new(@user) }

  it_behaves_like('(the existance of a method)', [:user, :associated_swimmer, :associated_teams, :uniq_team_mates, :socialize_with_team_mates])
  #-- -------------------------------------------------------------------------
  #++

  describe '#user' do
    it 'returns the user specified for this strategy' do
      expect(subject.user).to eq(@user)
    end
  end

  describe '#associated_swimmer' do
    it 'returns the associated swimmer of the user' do
      expect(subject.associated_swimmer).to eq(@user.swimmer)
    end
  end

  describe '#uniq_team_mates' do
    it 'returns the unique team mates of the user' do
      team_mates = @user.swimmer.teams.inject([]) { |memo, team| memo += team.swimmers.distinct }
      team_mates.uniq!
      expect(subject.uniq_team_mates.size).to eq(team_mates.size - 1)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#socialize_with_team_mates' do
    it 'adds friends to the user' do
      expect { subject.socialize_with_team_mates }.to change {
        @user.friends.size
      }
    end
    it 'adds all the team mates to the user' do
      subject.socialize_with_team_mates
      expect(subject.uniq_team_mates.size).to eq(@user.friends.size)
    end
    it "adds 'total sharing' friendships for each team mate" do
      subject.socialize_with_team_mates
      subject.uniq_team_mates.each do |swimmer|
        expect(@user.is_sharing_passages_with?(swimmer.associated_user)).to be true
        expect(@user.is_sharing_trainings_with?(swimmer.associated_user)).to be true
        expect(@user.is_sharing_calendars_with?(swimmer.associated_user)).to be true
      end
    end
    it 'does NOT create any NewsFeed for the @user' do
      expect { subject.socialize_with_team_mates }.not_to change { NewsFeed.count }
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
