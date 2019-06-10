# frozen_string_literal: true

require 'rails_helper'
require 'meeting_finder'

describe TeamFinder, type: :strategy do
  it_behaves_like('(the existance of a method)', [:search_ids, :search])
  #-- -------------------------------------------------------------------------
  #++

  context 'when no search term is supplied,' do
    subject { TeamFinder.new }

    describe '#search_ids' do
      it 'returns an empty list' do
        expect(subject.search_ids.size).to eq(0)
      end
    end
    describe '#search' do
      it 'returns an empty list' do
        expect(subject.search.count).to eq(0)
      end
    end
  end

  context 'when an empty search term is supplied,' do
    subject { TeamFinder.new('') }

    describe '#search_ids' do
      it 'returns an empty list' do
        expect(subject.search_ids.size).to eq(0)
      end
    end
    describe '#search' do
      it 'returns an empty list' do
        expect(subject.search.count).to eq(0)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when an existing search term is supplied (OBER, unlimited),' do
    subject { TeamFinder.new('ober') }

    describe '#search_ids' do
      it 'returns at least a Team row with the existing seeds' do
        result_count = subject.search_ids.size
        expect(result_count).to be > 0
        expect(result_count).to be < Team.count
      end
    end

    describe '#search' do
      it 'returns at least a Team row with the existing seeds' do
        result_count = subject.search.count
        expect(result_count).to be > 0
        expect(result_count).to be < Team.count
      end
      it 'returns a list of Team instances' do
        expect(subject.search).to all be_an_instance_of(Team)
      end
    end
  end

  context 'when an existing search term is supplied (AQUA, unlimited),' do
    subject { TeamFinder.new('aqua') }

    describe '#search_ids' do
      it 'returns more than 5 Team row IDs with the existing seeds' do
        result_count = subject.search_ids.size
        expect(result_count).to be > 5
        expect(result_count).to be < Team.count
      end
    end

    describe '#search' do
      it 'returns more than 5 Team rows with the existing seeds' do
        result_count = subject.search.count
        expect(result_count).to be > 5
        expect(result_count).to be < Team.count
      end
      it 'returns a list of Team instances' do
        expect(subject.search).to all be_an_instance_of(Team)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when an existing search term is supplied (AQUA, LIMIT: 5),' do
    subject { TeamFinder.new('aqua', 5) }

    describe '#search_ids' do
      it 'returns exactly 5 Team row IDs with the existing seeds' do
        result_count = subject.search_ids.size
        expect(result_count).to eq(5)
      end
    end

    describe '#search' do
      it 'returns exactly 5 Team rows with the existing seeds' do
        result_count = subject.search.count
        expect(result_count).to eq(5)
      end
      it 'returns a list of Team instances' do
        expect(subject.search).to all be_an_instance_of(Team)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when a non-existing search term is supplied,' do
    subject { TeamFinder.new('LARICIUMBALALLILLALLERO') }

    describe '#search_ids' do
      it 'returns an empty list' do
        result = subject.search_ids
        expect(result).to respond_to(:each)
        expect(result).to respond_to(:size)
        expect(result.size).to eq(0)
      end
    end
    describe '#search' do
      it 'returns an empty list' do
        result = subject.search
        expect(result).to respond_to(:each)
        expect(result).to respond_to(:size)
        expect(result.size).to eq(0)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
