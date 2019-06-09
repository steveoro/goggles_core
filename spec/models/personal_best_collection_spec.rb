# frozen_string_literal: true

require 'rails_helper'

describe PersonalBestCollection, type: :model do
  # Use pre-loaded seeds:
  let(:results)   { MeetingIndividualResult.where(swimmer_id: 23) }
  let(:fixture)   { results.to_a.at(((rand * 1000) % results.size).to_i) }
  let(:fixture2)  { results.to_a.at(((rand * 1000) % results.size).to_i) }
  let(:fixture3)  { results.to_a.at(((rand * 1000) % results.size).to_i) }

  let(:record_type_code)    { RecordType.find(1).code } # Assumes Swimmer personal best from seeds

  let(:pool_type_code)      { fixture.pool_type.code }
  let(:event_type_code)     { fixture.event_type.code }

  let(:pool_type_code2)     { fixture2.pool_type.code }
  let(:event_type_code2)    { fixture2.event_type.code }

  subject { PersonalBestCollection.new(fixture, record_type_code) }

  context '[implemented methods]' do
    it_behaves_like('(the existance of a method)',
                    [
                      :clear,
                      :each,
                      :count,                                     # included with Enumerable
                      :size,                                      # aliased from #count
                      :delete,
                      :delete_with_key,
                      :add,
                      :<<,
                      :get_record_for,
                      :has_record_for,
                      :has_any_record_for,
                      :encode_key_from_codes,
                      :encode_key_from_record,
                      :get_record_with_key,
                      :to_hash
                    ])
  end

  it 'implements the Enumerable interface' do
    expect(subject).to be_a_kind_of(Enumerable)
  end

  describe '#initialize' do
    it 'allows a MeetingIndividualResult instance as a parameter' do
      result = PersonalBestCollection.new(create(:meeting_individual_result, swimmer_id: 23), record_type_code)
      expect(result).to be_an_instance_of(PersonalBestCollection)
      expect(result.count).to eq(1)
    end
    it 'allows a list of MeetingIndividualResult rows as a parameter' do
      result = PersonalBestCollection.new(create_list(:meeting_individual_result, 3, swimmer_id: 23), record_type_code)
      expect(result).to be_an_instance_of(PersonalBestCollection)
      expect(result.count).to be > 0
    end
  end
  #-- -----------------------------------------------------------------------
  #++

  describe '#get_record_with_key' do
    it 'returns a nil when not found' do
      expect(subject.get_record_with_key('fake key')).to be_nil
    end
    it 'returns an instance of IndividualRecord when found' do
      subject.clear
      subject.add(fixture, record_type_code)
      key = subject.encode_key_from_record(fixture, record_type_code)
      expect(subject.get_record_with_key(key)).to be_an_instance_of(IndividualRecord)
    end
  end

  describe '#encode_key_from_codes' do
    it 'returns a String' do
      expect(subject.encode_key_from_codes('a', 'b', 'c')).to be_an_instance_of(String)
    end
    it 'contains all the specifed codes' do
      result = subject.encode_key_from_codes('a1', 'b2', 'b3')
      expect(result).to include('a1')
      expect(result).to include('b2')
      expect(result).to include('b3')
    end
  end

  describe '#encode_key_from_record' do
    it 'returns a String' do
      expect(
        subject.encode_key_from_record(fixture, record_type_code)
      ).to be_an_instance_of(String)
    end
    it 'contains all the specifed codes' do
      result = subject.encode_key_from_record(fixture, record_type_code)
      expect(result).to include(record_type_code)
      expect(result).to include(fixture.pool_type.code)
      expect(result).to include(fixture.event_type.code)
    end
  end

  describe '#to_hash' do
    it 'returns an instance of Hash' do
      expect(subject.to_hash).to be_an_instance_of(Hash)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#delete' do
    it 'returns true when successful' do
      subject.clear
      subject.add(fixture, record_type_code)
      expect(subject.delete(fixture, record_type_code)).to be true
    end
    it 'returns false when nothing has been done' do
      subject.clear
      expect(subject.delete(fixture, record_type_code)).to be false
    end
    it 'removes the specified element from the internal list' do
      subject.delete(fixture, record_type_code)
      expect(
        subject.has_record_for(
          record_type_code,
          fixture.pool_type.code,
          fixture.event_type.code
        )
      ).to be false
    end
    it 'decreases the size of the internal list' do
      subject.add(fixture, record_type_code)
      expect { subject.delete(fixture, record_type_code) }.to change { subject.count }.by(-1)
    end
  end

  describe '#delete_with_key' do
    let(:encoded_key) do
      subject.encode_key_from_codes(
        record_type_code,
        fixture.pool_type.code,
        fixture.event_type.code
      )
    end
    it 'returns true when successful' do
      subject.clear
      subject.add(fixture, record_type_code)
      expect(subject.delete_with_key(encoded_key)).to be true
    end
    it 'returns false when nothing has been done' do
      subject.clear
      expect(subject.delete_with_key(encoded_key)).to be false
    end
    it 'removes the specified element from the internal list' do
      subject.delete_with_key(encoded_key)
      expect(
        subject.has_record_for(
          record_type_code,
          fixture.pool_type.code,
          fixture.event_type.code
        )
      ).to be false
    end
    it 'decreases the size of the internal list' do
      subject.add(fixture, record_type_code)
      expect { subject.delete_with_key(encoded_key) }.to change { subject.count }.by(-1)
    end
  end

  describe '#clear' do
    it 'returns this instance' do
      expect(subject.clear).to be_an_instance_of(PersonalBestCollection)
    end
    it 'clears the internal list' do
      subject.add(fixture3, record_type_code)
      expect { subject.clear }.to change { subject.count }.to(0)
    end
  end

  describe '#add' do
    it 'returns nil with nil parameters' do
      expect(subject.add(nil, nil)).to be_nil
      expect(subject.add(nil, record_type_code)).to be_nil
    end
    it 'returns the string key of the new element' do
      subject.clear
      expect(subject.add(fixture, record_type_code)).to be_an_instance_of(String)
    end
    it 'adds an element to the list' do
      subject.clear
      expect { subject.add(fixture2, record_type_code) }.to change { subject.count }.by(1)
    end
    it 'does not add twice the same element to the list' do
      subject.clear
      generated_fixture = create(:meeting_individual_result)
      expect  do
        subject.add(generated_fixture, record_type_code)
        subject.add(generated_fixture, record_type_code)
      end.to change { subject.count }.by(1)
    end
    it 'adds correctly 2 different records to the list' do
      subject.clear
      unique_mirs = MeetingIndividualResultFactoryTools.create_unique_result_list(create(:swimmer), 2)
      expect do
        subject.add(unique_mirs.first, record_type_code)
        subject.add(unique_mirs.last, record_type_code)
      end.to change { subject.count }.by(2)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#get_record_for' do
    before(:each) do
      subject.add(fixture, record_type_code)
      subject.add(fixture2, record_type_code)
    end

    it 'returns an instance of IndividualRecord' do
      expect(
        subject.get_record_for(record_type_code, pool_type_code, event_type_code)
      ).to be_an_instance_of(IndividualRecord)
    end
    it 'returns the corresponding individual result for the specified keys' do
      result = subject.get_record_for(record_type_code, pool_type_code, event_type_code)
      expect(result.record_type.code).to eq(record_type_code)
      expect(result.pool_type.code).to   eq(pool_type_code)
      expect(result.event_type.code).to  eq(event_type_code)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#has_record_for' do
    before(:each) do
      subject.add(fixture, record_type_code)
      subject.add(fixture2, record_type_code)
    end

    it 'returns true for an existing record' do
      expect(
        subject.has_record_for(record_type_code, pool_type_code2, event_type_code2)
      ).to be true
    end
    it 'returns false for a non existing record' do
      expect(
        subject.has_record_for('FAKE', '45', '455FA')
      ).to be false
      expect(
        subject.has_record_for('FAKE', '25', '50FA')
      ).to be false
      expect(
        subject.has_record_for('SPB', 'FAKE', '50FA')
      ).to be false
      expect(
        subject.has_record_for('SPB', '25', 'FAKE')
      ).to be false
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#has_any_record_for' do
    it 'returns true for an existing record' do
      subject.add(fixture2, RecordType.find(2).code)
      expect(
        subject.has_any_record_for(pool_type_code, event_type_code)
      ).to be true
      expect(
        subject.has_any_record_for(pool_type_code2, event_type_code2)
      ).to be true
    end
    it 'returns false for a non existing record' do
      expect(
        subject.has_any_record_for('fake', event_type_code)
      ).to be false
      expect(
        subject.has_any_record_for(pool_type_code, 'fake')
      ).to be false
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
