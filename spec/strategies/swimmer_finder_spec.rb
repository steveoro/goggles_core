# rubocop:disable Style/FrozenStringLiteralComment

require 'rails_helper'
require 'meeting_finder'

describe SwimmerFinder, type: :strategy, tag: :finder do
  it_behaves_like('(the existance of a method)', [:search_ids, :search])
  #-- -------------------------------------------------------------------------
  #++

  context 'when no search term is supplied,' do
    subject { SwimmerFinder.new }

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
    subject { SwimmerFinder.new('') }

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

  context "when an existing search term is supplied ('alloro')," do
    subject { SwimmerFinder.new('alloro') }

    describe '#search_ids' do
      it 'returns more than 1 Swimmer row ID with the existing seeds' do
        result_count = subject.search_ids.size
        expect(result_count).to be > 1
        expect(result_count).to be < Swimmer.count
      end
    end

    describe '#search' do
      it 'returns more than 1 Swimmer row with the existing seeds' do
        result_count = subject.search.count
        expect(result_count).to be > 1
        expect(result_count).to be < Swimmer.count
      end
      it 'returns a list of Swimmer instances' do
        expect(subject.search).to all be_an_instance_of(Swimmer)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when a multi-matching search term is supplied (ROSSI, unlimited),' do
    subject { SwimmerFinder.new('rossi') }

    describe '#search_ids' do
      it 'returns more than 5 Swimmer row IDs with the existing seeds' do
        result_count = subject.search_ids.size
        expect(result_count).to be > 5
        expect(result_count).to be < Swimmer.count
      end
    end

    describe '#search' do
      it 'returns more than 5 Swimmer rows with the existing seeds' do
        result_count = subject.search.count
        expect(result_count).to be > 5
        expect(result_count).to be < Swimmer.count
      end
      it 'returns a list of Swimmer instances' do
        expect(subject.search).to all be_an_instance_of(Swimmer)
      end
    end
  end

  context 'when a multi-matching search term is supplied (ROSSI, LIMIT:5),' do
    subject { SwimmerFinder.new('rossi', 5) }

    describe '#search_ids' do
      it 'returns exactly 5 Swimmer row IDs with the existing seeds' do
        result_count = subject.search_ids.size
        expect(result_count).to eq(5)
        expect(result_count).to be < Swimmer.count
      end
    end

    describe '#search' do
      it 'returns exactly 5 Swimmer rows with the existing seeds' do
        result_count = subject.search.count
        expect(result_count).to eq(5)
        expect(result_count).to be < Swimmer.count
      end
      it 'returns a list of Swimmer instances' do
        expect(subject.search).to all be_an_instance_of(Swimmer)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when a non-existing search term is supplied,' do
    subject { SwimmerFinder.new('LARICIUMBALALLILLALLERO') }

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
# rubocop:enable Style/FrozenStringLiteralComment
