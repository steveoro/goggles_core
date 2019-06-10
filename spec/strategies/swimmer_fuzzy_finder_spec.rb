# rubocop:disable Style/FrozenStringLiteralComment

require 'rails_helper'

require 'meeting_finder'

describe SwimmerFuzzyFinder, type: :strategy, tag: :finder do
  context 'when no search term is supplied,' do
    describe 'self.call' do
      it 'raises an error' do
        expect do
          SwimmerFuzzyFinder.call
        end.to raise_error(ArgumentError)
      end
    end
  end

  context 'when an empty first+last name couple is supplied,' do
    subject { SwimmerFuzzyFinder.call(first_name: '', last_name: '') }
    describe 'self.call' do
      it 'returns an empty list' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        expect(subject.size).to eq(0)
      end
    end
  end

  context 'when an empty complete name is supplied,' do
    subject { SwimmerFuzzyFinder.call(complete_name: '') }
    describe 'self.call' do
      it 'returns an empty list' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        expect(subject.size).to eq(0)
      end
    end
  end

  context 'when a non-existing search term is supplied,' do
    subject do
      SwimmerFuzzyFinder.call(
        first_name: 'Not-A-Name',
        last_name: 'Not-A-Surname'
      )
    end
    describe 'self.call' do
      it 'returns an empty list' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        expect(subject.size).to eq(0)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when a single-matching first+last name couple is supplied,' do
    subject do
      SwimmerFuzzyFinder.call(
        first_name: 'Stefano',
        last_name: 'Alloro',
        year_of_birth: '1969'
      )
    end
    describe 'self.call' do
      it 'returns the matching Swimmer' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        expect(subject.size).to eq(1)
        expect(subject.first).to be_a(Swimmer)
        expect(subject.first.first_name).to eq('Stefano'.upcase)
        expect(subject.first.last_name).to eq('Alloro'.upcase)
        expect(subject.first.year_of_birth).to eq(1969)
      end
    end
  end

  context 'when a single-matching complete, reversed name is supplied,' do
    subject do
      SwimmerFuzzyFinder.call(
        complete_name: 'Stefano Alloro',
        year_of_birth: '1969'
      )
    end
    describe 'self.call' do
      it 'returns the matching Swimmer' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        expect(subject.size).to eq(1)
        expect(subject.first).to be_a(Swimmer)
        expect(subject.first.first_name).to eq('Stefano'.upcase)
        expect(subject.first.last_name).to eq('Alloro'.upcase)
        expect(subject.first.year_of_birth).to eq(1969)
      end
    end
  end

  context 'when a single-matching complete name is supplied,' do
    subject do
      SwimmerFuzzyFinder.call(
        complete_name: 'Alloro Stefano',
        year_of_birth: '1969'
      )
    end
    describe 'self.call' do
      it 'returns the matching Swimmer' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        expect(subject.size).to eq(1)
        expect(subject.first).to be_a(Swimmer)
        expect(subject.first.first_name).to eq('Stefano'.upcase)
        expect(subject.first.last_name).to eq('Alloro'.upcase)
        expect(subject.first.year_of_birth).to eq(1969)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'when a multi-matching first+last name couple is supplied,' do
    subject do
      SwimmerFuzzyFinder.call(
        first_name: 'Andrea',
        last_name: 'Rossi'
      )
    end
    describe 'self.call' do
      it 'returns a list of matching Swimmers' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        expect(subject.size).to be > 1
        expect(subject).to all be_a(Swimmer)
      end
    end
  end

  context 'when a multi-matching complete_name is supplied,' do
    subject do
      SwimmerFuzzyFinder.call(
        complete_name: 'rossi andrea'
      )
    end
    describe 'self.call' do
      it 'returns a list of matching Swimmers' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        expect(subject.size).to be >= 2
        expect(subject).to all be_a(Swimmer)
      end
    end
  end

  context 'when a multi-matching last name is supplied,' do
    subject do
      SwimmerFuzzyFinder.call(
        last_name: 'Alloro'
      )
    end
    describe 'self.call' do
      it 'returns a list of matching Swimmers' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        expect(subject.size).to be >= 2
        expect(subject).to all be_a(Swimmer)
        expect(subject.map(&:last_name))
          .to include('Alloro'.upcase, 'Cavalloro'.upcase)
      end
    end
  end

  context "when a multi-matching 'partial' complete_name is supplied (ALLORO, unlimited)," do
    subject do
      SwimmerFuzzyFinder.call(complete_name: 'Alloro')
    end
    describe 'self.call' do
      it 'returns a list of matching Swimmers' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        expect(subject.size).to be >= 2
        expect(subject).to all be_a(Swimmer)
        expect(subject.map(&:last_name))
          .to include('Alloro'.upcase, 'Cavalloro'.upcase)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "when a multi-matching 'partial' complete_name is supplied (ROSSI, unlimited)," do
    subject do
      SwimmerFuzzyFinder.call(complete_name: 'rossi')
    end
    describe 'self.call' do
      it 'returns a list of matching Swimmers' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        # DEBUG
        #        puts "\r\n- SwimmerFuzzyFinder.call('rossi') UNLIMITED results count: #{ subject.size }"
        expect(subject.size).to be > 5
        expect(subject).to all be_a(Swimmer)
        expect(subject.map(&:last_name))
          .to include('rossi'.upcase)
      end
    end
  end

  context "when a multi-matching 'partial' complete_name is supplied (ROSSI, LIMIT: 5)," do
    subject do
      SwimmerFuzzyFinder.call(complete_name: 'rossi', limit: 5)
    end
    describe 'self.call' do
      it 'returns a list of matching Swimmers' do
        expect(subject).to respond_to(:each)
        expect(subject).to respond_to(:size)
        expect(subject.size).to eq(5)
        expect(subject).to all be_a(Swimmer)
        expect(subject.map(&:last_name))
          .to include('rossi'.upcase)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
# rubocop:enable Style/FrozenStringLiteralComment
