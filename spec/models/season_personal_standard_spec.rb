# frozen_string_literal: true

require 'rails_helper'

describe SeasonPersonalStandard, type: :model do
  it_behaves_like 'SwimmerRelatable'
  it_behaves_like 'TimingGettable'
  # ---------------------------------------------------------------------------
  #++

  subject { create(:season_personal_standard) }

  context '[a well formed instance]' do
    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:season, :event_type, :pool_type])
    # Filtering scopes:
    it_behaves_like('(the existance of a class method)', [:for_season, :for_swimmer, :for_event_type, :for_pool_type, :for_event_and_pool])

    context '[general methods]' do
      it_behaves_like('(the existance of a method returning non-empty strings)', [:get_short_name, :get_full_name, :get_verbose_name, :get_event_type, :get_pool_type])
    end
  end

  describe '#has_standard? method' do
    it 'responds to #has_standard?' do
      expect(subject.class).to respond_to(:has_standard?)
    end
    it 'returns a boolean' do
      fix_season_id     = 151  # 2015/2016 CSI season
      fix_swimmer_id    = 23   # Leega
      fix_pool_type_id  = PoolType.only_for_meetings[((rand * 100) % PoolType.only_for_meetings.count).to_i].id
      fix_event_type_id = EventType.are_not_relays[((rand * 100) % EventType.are_not_relays.count).to_i].id
      result = subject.class.has_standard?(fix_season_id, fix_swimmer_id, fix_pool_type_id, fix_event_type_id)
      if result
        expect(result == true).to be true
      else
        expect(result == false).to be true
      end
    end
    it 'returns true if standard present' do
      expect(subject.class.has_standard?(subject.season_id, subject.swimmer_id, subject.pool_type_id, subject.event_type_id)).to be true
    end
    it 'returns false if standard not present' do
      # Assumes id given doesn't exists
      expect(subject.class.has_standard?(154_123, 12_568, 1230, 0)).to be false
    end
  end
  # ---------------------------------------------------------------------------
  #++

  describe '#get_standard method' do
    it 'responds to #get_standard' do
      expect(subject.class).to respond_to(:get_standard)
    end
    it 'returns an ActiveRecord object or nil' do
      fix_season_id     = 151  # 2015/2016 CSI season
      fix_swimmer_id    = 23   # Leega
      fix_pool_type_id  = PoolType.only_for_meetings[((rand * 100) % PoolType.only_for_meetings.count).to_i].id
      fix_event_type_id = EventType.are_not_relays[((rand * 100) % EventType.are_not_relays.count).to_i].id
      expect(subject.class.get_standard(fix_season_id, fix_swimmer_id, fix_pool_type_id, fix_event_type_id)).to be_a_kind_of(ActiveRecord::Base).or be_nil
    end
    it 'returns a SeasonPersonalStandard if standard present' do
      expect(subject.class.get_standard(subject.season_id, subject.swimmer_id, subject.pool_type_id, subject.event_type_id)).to be_an_instance_of(SeasonPersonalStandard)
    end
    it 'returns nil if standard not present' do
      # Assumes id given doesn't exists
      expect(subject.class.get_standard(154_123, 12_568, 1230, 0)).to be_nil
    end
  end
  # ---------------------------------------------------------------------------
  #++
end
