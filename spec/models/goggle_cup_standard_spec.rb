# frozen_string_literal: true

require 'rails_helper'

describe GoggleCupStandard, type: :model do
  it_behaves_like 'SwimmerRelatable'
  it_behaves_like 'TimingGettable'
  # ---------------------------------------------------------------------------
  #++

  context '[a well formed instance]' do
    subject { create(:goggle_cup_standard) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:goggle_cup, :event_type, :pool_type])
    # Filtering scopes:
    it_behaves_like('(the existance of a class method)', [:sort_by_user, :sort_by_goggle_cup, :sort_by_swimmer, :sort_by_event_type, :sort_by_pool_type])

    context '[general methods]' do
      it_behaves_like('(the existance of a method returning non-empty strings)', [:get_short_name, :get_full_name, :get_verbose_name, :get_event_type, :get_pool_type])
    end
  end

  describe 'class #has_standard? method' do
    it 'responds to #has_standard?' do
      expect(subject.class).to respond_to(:has_standard?)
    end
    it 'returns a boolean' do
      fix_goggle_cup_id = 8
      fix_swimmer_id    = 23
      fix_pool_type_id  = PoolType.only_for_meetings[((rand * 100) % PoolType.only_for_meetings.count).to_i].id
      fix_event_type_id = EventType.are_not_relays[((rand * 100) % EventType.are_not_relays.count).to_i].id
      result = subject.class.has_standard?(fix_goggle_cup_id, fix_swimmer_id, fix_pool_type_id, fix_event_type_id)
      if result
        expect(result == true).to be true
      else
        expect(result == false).to be true
      end
    end
    it 'returns true if standard present' do
      # Assumes Leega, ober cup 2014, 50FA, 25 mt
      fix_goggle_cup_id = 8
      fix_swimmer_id    = 23
      fix_event_type_id = 11
      fix_pool_type_id  = 1
      expect(subject.class.has_standard?(fix_goggle_cup_id, fix_swimmer_id, fix_pool_type_id, fix_event_type_id)).to be true
    end
    it 'returns false if standard not present' do
      # Assumes id given doesn't exists
      expect(subject.class.has_standard?(154_123, 12_568, 4, 185)).to be false
    end
  end
  # ---------------------------------------------------------------------------
  #++

  describe 'class #get_standard method' do
    it 'responds to #get_standard' do
      expect(subject.class).to respond_to(:get_standard)
    end
    it 'returns an ActiveRecord object or nil' do
      fix_goggle_cup_id = 8
      fix_swimmer_id    = 23
      fix_pool_type_id  = PoolType.only_for_meetings[((rand * 100) % PoolType.only_for_meetings.count).to_i].id
      fix_event_type_id = EventType.are_not_relays[((rand * 100) % EventType.are_not_relays.count).to_i].id
      expect(subject.class.get_standard(fix_goggle_cup_id, fix_swimmer_id, fix_pool_type_id, fix_event_type_id)).to be_a_kind_of(ActiveRecord::Base).or be_nil
    end
    it 'returns a GoggleCupStandard if standard present' do
      # Assumes Leega, ober cup 2014, 50FA, 25 mt
      fix_goggle_cup_id = 8
      fix_swimmer_id    = 23
      fix_event_type_id = 11
      fix_pool_type_id  = 1
      expect(subject.class.get_standard(fix_goggle_cup_id, fix_swimmer_id, fix_pool_type_id, fix_event_type_id)).to be_an_instance_of(GoggleCupStandard)
    end
    it 'returns nil if standard not present' do
      # Assumes id given doesn't exists
      expect(subject.class.get_standard(154_123, 12_568, 4, 185)).to be_nil
    end
  end
  # ---------------------------------------------------------------------------
  #++
end
