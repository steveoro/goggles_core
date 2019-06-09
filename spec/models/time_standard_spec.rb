# frozen_string_literal: true

require 'rails_helper'

describe TimeStandard, type: :model do
  it_behaves_like 'TimingGettable'
  #-- -------------------------------------------------------------------------
  #++

  describe '#has_standard? method' do
    it 'responds to #has_standard?' do
      expect(subject.class).to respond_to(:has_standard?)
    end
    it 'returns a boolean' do
    end
    it 'returns true if standard present' do
    end
    it 'returns false if standard not present' do
      # Assumes id given doesn't exists
      expect(subject.class.has_standard?(154_123, -560, 1230, 15, 0)).to be false
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#get_standard method' do
    it 'responds to #get_standard' do
      expect(subject.class).to respond_to(:get_standard)
    end
    it 'returns an ActiveRecord object or nil' do
    end
    it 'returns a SeasonPersonalStandard if standard present' do
    end
    it 'returns nil if standard not present' do
      # Assumes id given doesn't exists
      expect(subject.class.get_standard(154_123, -560, 1230, 15, 0)).to be_nil
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
