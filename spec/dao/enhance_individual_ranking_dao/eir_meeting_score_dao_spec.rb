# frozen_string_literal: true

require 'rails_helper'

describe EnhanceIndividualRankingDAO::EIRMeetingScoreDAO, type: :model do
  let(:season)  { Season.find(151) }
  let(:meeting) { season.meetings.has_results[(rand * (season.meetings.has_results.count - 1)).to_i] }
  # FIXME: PEZZI STEFY: 1788 - IDO ORLA: 64
  let(:swimmer) { Swimmer.find(1788) } # PEZZI STEFANIA
  #  let(:swimmer) { meeting.swimmers[ (rand * (meeting.swimmers.count - 1)).to_i ] }
  let(:mirs)    { meeting.meeting_individual_results.is_valid.where(['meeting_individual_results.swimmer_id = ?', swimmer.id]) }

  subject { EnhanceIndividualRankingDAO::EIRMeetingScoreDAO.new(meeting, mirs) }

  it_behaves_like('(the existance of a method)', [:header_date, :event_bonus_points, :medal_bonus_points, :event_points, :performance_points, :enhance_points, :event_results, :get_total_points])

  describe '#header_date' do
    it 'is the header date for the meeting used in construction' do
      expect(subject.header_date).to eq(meeting.header_date)
    end
  end

  describe '#event_bonus_points' do
    it 'is a value between 0 and 8' do
      expect(subject.event_bonus_points).to be >= 0
      expect(subject.event_bonus_points).to be <= 8
    end
  end

  describe '#medal_bonus_points' do
    it 'is a value between 0 and 10' do
      expect(subject.medal_bonus_points).to be >= 0
      expect(subject.medal_bonus_points).to be <= 10
    end
  end

  describe '#event_points' do
    it 'is a value between 0 and 100' do
      expect(subject.event_points).to be >= 0
      expect(subject.event_points).to be <= 100
    end
  end

  # FIXME: RANDOM FAILURE HERE:
  describe '#performance_points' do
    xit 'is a value between 0 and 100' do
      # DEBUG
      if subject.performance_points > 100
        puts "\r\nFAILING FOR: meeting: #{meeting.get_full_name}, ID: #{meeting.id}"
        puts "- mirs count: #{mirs.count}"
        puts "- subject: #{subject.inspect}\r\n"
      end
      expect(subject.performance_points).to be >= 0
      expect(subject.performance_points).to be <= 100
    end
  end

  describe '#enhance_points' do
    it 'is a value between 0 and 10' do
      expect(subject.enhance_points).to be >= 0
      expect(subject.enhance_points).to be <= 10
    end
  end

  describe '#event_results' do
    it 'is a collection of BIREventScoreDAO' do
      expect(subject.event_results).to be_a_kind_of(Enumerable)
      expect(subject.event_results).to all(be_a_kind_of(EnhanceIndividualRankingDAO::EIREventScoreDAO))
    end
    it 'is has an instance per each meeting individual result used in construction' do
      expect(subject.event_results.count).to eq(mirs.count)
    end
  end

  describe '#get_total_points' do
    it 'is a value between 0 and 278 (100 + 150 + 10 + 10 + 8)' do
      expect(subject.get_total_points).to be >= 0
      expect(subject.get_total_points).to be <= 278
    end
    it 'is the sum of event_points, performance_points, enhance_points, ranking_points, medal_bonus and hard event_bonus' do
      expect(subject.get_total_points).to eq(subject.event_points + subject.performance_points + subject.enhance_points + subject.event_bonus_points + subject.medal_bonus_points)
    end
  end

  describe '#get_meeting_scores_detail' do
    it 'returns a string' do
      expect(subject.get_meeting_scores_detail).to be_a_kind_of(String)
    end
  end
end
#-- ---------------------------------------------------------------------------
#++
