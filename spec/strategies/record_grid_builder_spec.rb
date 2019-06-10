# rubocop:disable Style/FrozenStringLiteralComment

require 'rails_helper'

describe RecordGridBuilder, type: :strategy do
  let(:individual_record_list) do
    # Force a list of completely different records, with random swimmers and
    # random, unique events:
    IndividualRecordFactoryTools.create_personal_best_list
  end

  # Using a pre-filled collector will speed-up the tests:
  subject { RecordGridBuilder.new(RecordCollector.new(list: individual_record_list)) }

  context '[implemented methods]' do
    it_behaves_like('(the existance of a method)',
                    [:cache_key, :collection, :count, :event_types])
    it_behaves_like('(the existance of a method returning a collection of some kind of instances)',
                    [:pool_types, :category_types, :gender_types],
                    ActiveRecord::Base)
  end

  describe '#initialize' do
    it 'allows an instance of RecordCollector as a parameter' do
      expect(subject).to be_an_instance_of(RecordGridBuilder)
      expect(subject.count).to eq(individual_record_list.size)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#cache_key' do
    it 'returns a String' do
      expect(subject.cache_key).to be_an_instance_of(String)
    end
    it 'returns a non empty string' do
      expect(subject.cache_key.size).to be >= 1
    end
    it 'contains at least as many numbers as there are elements in the collection' do
      expect(subject.cache_key.split('-').count).to be >= subject.collection.count
    end
  end
  #-- -----------------------------------------------------------------------
  #++

  describe '#collection' do
    it 'returns the collection instance' do
      expect(subject.collection).to be_an_instance_of(RecordCollection)
    end
    # This is useful if the getter is implemented using #dup or #clone.
    # [Steve, 20140717] *** Currently: NOT ***
    it 'returns a collection having the same number of elements of the internal collection' do
      expect(subject.collection.count).to eq(subject.count)
    end
  end

  describe '#count' do
    it 'returns the size of the internal collection' do
      expect(subject.count > 0).to be true
    end
    it 'gets updated when the internal list changes' do
      expect { subject.collection.clear }.to change { subject.count }.to(0)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # This is testing an empty grid:
  context 'when building a grid for season with NO records,' do
    let(:fake_season_type)  { FactoryBot.create(:season_type) }
    let(:records)           { IndividualRecord.for_season_type(fake_season_type.id) }
    let(:collector)         { RecordCollector.new(list: records, record_type_code: 'FOR', season_type: fake_season_type) }

    subject { RecordGridBuilder.new(collector, 'FOR') }

    describe '#initialize' do
      it 'receives 0 records' do
        expect(records.count).to eq(0)
      end
      it 'receives a Collector instance' do
        expect(collector).to be_a(RecordCollector)
      end
      it 'receives a Collector with a valid Collection' do
        expect(collector.collection).to be_a(RecordCollection)
      end

      it 'builds the instance' do
        expect(subject).to be_a(RecordGridBuilder)
      end
      it 'has a #count of 0 (records)' do
        expect(subject.count).to eq(0)
      end
      it 'has a #collection that responds to :each and :count' do
        expect(subject.collection).to respond_to(:each)
        expect(subject.collection).to respond_to(:count)
      end
      it 'has a 0 category_types' do
        expect(subject.category_types.size).to eq(0)
      end
      it 'has all the event_types for pool_type #1 (25 mt.)' do
        expect(subject.event_types(1).size).to be > 0
      end
      it 'has all the event_types for pool_type #2 (50 mt.)' do
        expect(subject.event_types(2).size).to be > 0
      end
      it 'has always 2 gender_types' do
        expect(subject.gender_types.size).to eq(2)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
# rubocop:enable Style/FrozenStringLiteralComment
