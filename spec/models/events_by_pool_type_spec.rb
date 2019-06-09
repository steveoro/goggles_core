# frozen_string_literal: true

require 'rails_helper'

describe EventsByPoolType, type: :model do
  # subject { create(:events_by_pool_type) }
  # Assumes presence in seeds
  subject { EventsByPoolType.find(((rand * 100) % EventsByPoolType.count).to_i + 1) }

  context 'well formed instance' do
    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:pool_type, :event_type])
    # Filtering scopes:
    it_behaves_like('(the existance of a class method)', [:are_relays, :not_relays, :only_for_meetings, :for_pool_type_code, :sort_by_pool, :sort_by_event, :find_by_key, :get_event_types_for_pool_type_by_code, :get_pool_types_for_event_type_by_code, :get_events_by_pool_type_array])
    # Has_one relationships:
    it_behaves_like('(it has_one of these required models)', [
                      :stroke_type
                    ])

    it_behaves_like('(the existance of a method returning non-empty strings)', [:i18n_short, :i18n_description])

    describe '#find_by_pool_and_event_codes' do
      it 'returns a EventsByPool instance or nil' do
        fix_pool_code  = PoolType.find(((rand * 100) % 3).to_i + 1).code
        fix_event_code = EventType.find(((rand * 100) % 30).to_i + 1).code
        expect(EventsByPoolType.find_by(pool: fix_pool_code, event_codes: fix_event_code)).to be_an_instance_of(EventsByPoolType).or be_nil
      end
      it 'returns a EventsByPool instance if present' do
        expect(EventsByPoolType.find_by(pool: subject.pool_type.code, event_codes: subject.event_type.code)).to be_an_instance_of(EventsByPoolType)
      end
      it 'returns nil if no event for the pool type present' do
        expect(EventsByPoolType.find_by(pool: '50', event_codes: '100MI')).to be_nil
      end
    end

    describe '#find_by_key' do
      it 'returns a EventsByPool instance or nil' do
        fix_key = "#{PoolType.find(((rand * 100) % 3).to_i + 1).code}-#{EventType.find(((rand * 100) % 30).to_i + 1).code}"
        expect(EventsByPoolType.find_by(key: fix_key)).to be_an_instance_of(EventsByPoolType).or be_nil
      end
      it 'returns a EventsByPool instance if present' do
        expect(EventsByPoolType.find_by(key: "#{subject.event_type.code}-#{subject.pool_type.code}")).to be_an_instance_of(EventsByPoolType)
      end
      it 'returns nil if no event for the pool type present' do
        expect(EventsByPoolType.find_by(key: '100MI-50')).to be_nil
      end
    end

    describe '#get_event_types_for_pool_type_by_code' do
      it 'responds to each' do
        fix_pool_code = PoolType.find(((rand * 10) % 3).to_i + 1).code
        expect(EventsByPoolType.get_event_types_for_pool_type_by_code(fix_pool_code)).to respond_to(:each)
      end
      it 'responds to count' do
        fix_pool_code = PoolType.find(((rand * 10) % 3).to_i + 1).code
        expect(EventsByPoolType.get_event_types_for_pool_type_by_code(fix_pool_code)).to respond_to(:count)
      end
      it 'returns a collection of event types' do
        fix_pool_code = PoolType.find(((rand * 10) % 3).to_i + 1).code
        expect(EventsByPoolType.get_event_types_for_pool_type_by_code(fix_pool_code))
          .to all(be_an(EventType))
      end
    end

    describe 'self.get_pool_types_for_event_type_by_code' do
      it 'responds to each' do
        fix_event_code = EventType.find(((rand * 10) % 3).to_i + 1).code
        expect(EventsByPoolType.get_pool_types_for_event_type_by_code(fix_event_code)).to respond_to(:each)
      end
      it 'responds to count' do
        fix_event_code = EventType.find(((rand * 10) % 3).to_i + 1).code
        expect(EventsByPoolType.get_pool_types_for_event_type_by_code(fix_event_code)).to respond_to(:count)
      end
      it 'returns a collection of pool types' do
        fix_event_code = EventType.find(((rand * 10) % 3).to_i + 1).code
        expect(EventsByPoolType.get_pool_types_for_event_type_by_code(fix_event_code))
          .to all(be_an(PoolType))
      end
    end

    describe 'self.get_events_by_pool_type_array' do
      it 'returns an Hash' do
        expect(EventsByPoolType.get_events_by_pool_type_array).to be_an(Hash)
      end
      it 'returns a non empty set' do
        expect(EventsByPoolType.get_events_by_pool_type_array.count).to be > 0
      end
      it 'returns an Hash having ActiveRecord::Relation as values' do
        expect(EventsByPoolType.get_events_by_pool_type_array.values).to all be_an(ActiveRecord::Relation)
      end
      it 'returns a collection of event types (referred by a relation)' do
        expect(EventsByPoolType.get_events_by_pool_type_array.values.first.all.to_a)
          .to all(be_an(EventType))
        expect(EventsByPoolType.get_events_by_pool_type_array.values.last.all.to_a)
          .to all(be_an(EventType))
      end
    end
  end
end
