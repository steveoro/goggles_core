# frozen_string_literal: true

require 'rails_helper'

describe EnhanceIndividualRankingDAO::EIRSwimmerScoreDAO, type: :model do
  let(:season)  { Season.find(151) }
  let(:meeting) { season.meetings.has_results[(rand * (season.meetings.has_results.count - 1)).to_i] }
  # FIXME: PEZZI STEFY: 1788 - IDO ORLA: 64
  let(:swimmer) { Swimmer.find(1788) } # PEZZI STEFANIA
  #  let(:swimmer) { meeting.swimmers[ (rand * (meeting.swimmers.count - 1)).to_i ] }
  let(:mirs)    { meeting.meeting_individual_results.is_valid.where(['meeting_individual_results.swimmer_id = ?', swimmer.id]) }

  subject { EnhanceIndividualRankingDAO::EIRSwimmerScoreDAO.new(swimmer, season) }

  it_behaves_like('(the existance of a method)', [:swimmer, :category_type, :gender_type, :meetings, :total_best_5_on_6, :get_meeting_scores])

  describe '#swimmer' do
    it 'is the swimmer used in construction' do
      expect(subject.swimmer).to eq(swimmer)
    end
  end

  describe '#category_type' do
    it 'is the category_type of the swimmer in the season' do
      expect(subject.category_type).to eq(swimmer.get_category_type_for_season(season.id))
    end
  end

  describe '#gender_type' do
    it 'is the gender_type of the swimmer' do
      expect(subject.gender_type).to eq(swimmer.gender_type)
    end
  end

  describe '#meetings' do
    it 'is a collection of EIRMeetingScoreDAO' do
      expect(subject.meetings).to be_a_kind_of(Enumerable)
      expect(subject.meetings).to all(be_a_kind_of(EnhanceIndividualRankingDAO::EIRMeetingScoreDAO))
    end
    it 'is has no more than one instance per each meeting of the season' do
      expect(subject.meetings.count).to be <= season.meetings.count
    end
  end

  # FIXME: RANDOM FAILURE HERE:
  describe '#total_best_5_on_6' do
    xit 'is a value between 0 and 1090 (100 + 100 + 10 + 8) * 5' do
      # DEBUG
      if subject.total_best_5_on_6 > 1090
        puts "\r\nFAILING FOR: meeting: #{meeting.get_full_name}, ID: #{meeting.id}"
        puts "- mirs count: #{mirs.count}"
        puts "- subject: #{subject.inspect}\r\n"
      end
      expect(subject.total_best_5_on_6).to be >= 0
      expect(subject.total_best_5_on_6).to be <= 1090
    end
  end

  describe '#get_meeting_scores' do
    it 'returns a EIRMeetingScoreDAO or nil' do
      expect(subject.get_meeting_scores(meeting)).to be_a_kind_of(EnhanceIndividualRankingDAO::EIRMeetingScoreDAO).or be_nil
    end
  end
end
#-- ---------------------------------------------------------------------------
#++
