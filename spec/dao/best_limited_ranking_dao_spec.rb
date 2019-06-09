# frozen_string_literal: true

require 'rails_helper'

describe BestLimitedRankingDAO, type: :model do
  let(:season)  { Season.find(142) }
  let(:team)    { Team.find(1) }
  let(:swimmer) { season.badges.for_team(team)[((rand * season.badges.for_team(team).count) % season.badges.for_team(team).count).to_i].swimmer }
  let(:mirs)    { swimmer.meeting_individual_results.for_season(season).limit(5) }

  let(:sum_of_mirs) { mirs.collect(&:standard_points).sum }

  let(:fix_mir_min) { create(:meeting_individual_result, standard_points: 750.00, goggle_cup_points: 950.00) }
  let(:fix_mir_avg) { create(:meeting_individual_result, standard_points: 800.00, goggle_cup_points: 1000.00) }
  let(:fix_mir_max) { create(:meeting_individual_result, standard_points: 850.00, goggle_cup_points: 1050.00) }
  let(:fix_mirs)    { [fix_mir_min, fix_mir_max, fix_mir_avg] }

  it_behaves_like('(the existance of a method)', [:results, :number, :score, :average, :min, :max, :get_results_number, :get_score, :get_average, :get_min, :get_max, :reset])

  context 'initialization without parameters,' do
    subject { BestLimitedRankingDAO.new }

    describe '#results' do
      it 'is a collection of meeting individual results' do
        expect(subject.results).to be_a_kind_of(Enumerable)
        expect(subject.results.count).to eq(0)
      end
    end
    describe '#number' do
      it 'is a numeric value' do
        expect(subject.number).to eq(0)
      end
    end
    describe '#score' do
      it 'is a numeric value' do
        expect(subject.score).to eq(0)
      end
    end
    describe '#average' do
      it 'is a numeric value' do
        expect(subject.average).to eq(0)
      end
    end
    describe '#min' do
      it 'is a numeric value' do
        expect(subject.min).to eq(0)
      end
    end
    describe '#max' do
      it 'is a numeric value' do
        expect(subject.max).to eq(0)
      end
    end
  end

  context 'initialization with meeting individual results as parameter,' do
    subject { BestLimitedRankingDAO.new(mirs) }

    describe '#results' do
      it 'is a collection of meeting individual results' do
        expect(subject.results).to all(be_an_instance_of(MeetingIndividualResult))
        expect(subject.results.count).to eq(mirs.count)
      end
    end
  end

  context 'with random data set' do
    subject { BestLimitedRankingDAO.new(mirs) }

    it 'contains congruent values' do
      expect(subject.max).to be >= subject.min
      expect(subject.score).to be >= subject.min
      expect(subject.average).to be >= subject.min
      expect(subject.average).to be <= subject.max
      expect(subject.number).to eq(subject.results.count)
    end

    describe '#reset' do
      it 'reset all dao values' do
        subject.reset
        expect(subject.results.count).to eq(0)
        expect(subject.number).to eq(0)
        expect(subject.max).to eq(0)
        expect(subject.score).to eq(0)
        expect(subject.average).to eq(0)
      end
    end

    describe '#get_results_number' do
      it 'returns a positive number' do
        expect(subject.get_results_number).to be >= 0
      end
      it 'returns the results elements count' do
        expect(subject.get_results_number).to eq(subject.results.count)
      end
    end

    describe '#get_score' do
      it 'returns a positive number' do
        expect(subject.get_score).to be >= 0
      end
      it 'returns the results standard points sum' do
        expect(subject.get_score).to eq(sum_of_mirs)
      end
    end

    describe '#get_average' do
      it 'returns a positive number' do
        expect(subject.get_average).to be >= 0
      end
      it 'returns the average value of score divided by number or 0' do
        if subject.results.count > 0
          expect(subject.get_average).to eq(sum_of_mirs / subject.results.count)
        else
          expect(subject.get_average).to eq(0)
        end
      end
    end

    describe '#get_min' do
      it 'returns a positive number' do
        expect(subject.get_min).to be >= 0
      end
      it 'returns the minimum value of standard points' do
        if subject.results.count > 0
          expect(subject.get_min).to eq(subject.results.last.standard_points)
        else
          expect(subject.get_min).to eq(0)
        end
      end
    end

    describe '#get_max' do
      it 'returns a positive number' do
        expect(subject.get_max).to be >= 0
      end
      it 'returns the maximum value of standard points' do
        if subject.results.count > 0
          expect(subject.get_max).to eq(subject.results.first.standard_points)
        else
          expect(subject.get_max).to eq(0)
        end
      end
    end
  end

  context 'with fix data set later,' do
    subject { BestLimitedRankingDAO.new }

    describe '#set_results' do
      it 'assigns given results' do
        expect(subject.results.size).to eq(0)
        expect(fix_mirs.count).to be > 0
        subject.set_results(fix_mirs)
        expect(subject.results.count).to eq(fix_mirs.count)
      end
      it 'calculates dao attributes' do
        expect(subject.number).to eq(0)
        subject.set_results(fix_mirs)
        expect(subject.number).to eq(fix_mirs.count)
        expect(subject.score).to eq(fix_mirs.collect(&:standard_points).sum)
        expect(subject.average).to eq(fix_mirs.collect(&:standard_points).sum / fix_mirs.count)
        expect(subject.min).to eq(750.00)
        expect(subject.max).to eq(850.00)
      end
      it 'contains sorted results' do
        subject.set_results(fix_mirs)
        max = subject.results.first.standard_points
        subject.results.each do |mir|
          expect(mir.standard_points).to be <= max
          max = mir.standard_points
        end
      end
    end

    describe '#add_results' do
      it 'assigns given results' do
        expect(subject.results.size).to eq(0)
        subject.add_result(fix_mir_min)
        expect(subject.results.count).to eq(1)
        subject.add_result(fix_mir_max)
        expect(subject.results.count).to eq(2)
      end
      it 'calculates dao attributes' do
        expect(subject.number).to eq(0)
        subject.add_result(fix_mir_avg)
        subject.add_result(fix_mir_min)
        subject.add_result(fix_mir_max)
        expect(subject.number).to eq(3)
        expect(subject.score).to eq(fix_mir_min.standard_points + fix_mir_avg.standard_points + fix_mir_max.standard_points)
        expect(subject.average).to eq(fix_mir_avg.standard_points)
        expect(subject.min).to eq(fix_mir_min.standard_points)
        expect(subject.max).to eq(fix_mir_max.standard_points)
      end
      it 'contains sorted results' do
        subject.add_result(fix_mir_avg)
        subject.add_result(fix_mir_min)
        subject.add_result(fix_mir_max)
        max = subject.results.first.standard_points
        subject.results.each do |mir|
          expect(mir.standard_points).to be <= max
          max = mir.standard_points
        end
      end
    end
  end

  context 'using non standard column,' do
    subject { BestLimitedRankingDAO.new(fix_mirs, :goggle_cup_points) }

    it 'calculate score with given column' do
      expect(subject.get_score).to eq(3000.00)
      expect(subject.get_average).to eq(1000.00)
      expect(subject.get_min).to eq(950.00)
      expect(subject.get_max).to eq(1050.00)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
