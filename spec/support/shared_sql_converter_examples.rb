# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'SqlConverter [param: let(:record)]' do
  let(:to_ignore) { %w[lock_version tags_by_user_list tags_by_team_list] }

  it_behaves_like('(the existance of a method)', [:to_sql_insert, :to_sql_update, :to_sql_delete, :destroy_with_sql_capture])

  describe '#to_sql_insert' do
    it 'returns a String' do
      expect(subject.to_sql_insert(record)).to be_an_instance_of(String)
    end
    it 'contains the table name' do
      sql_text = subject.to_sql_insert(record)
      expect(sql_text).to include(record.class.table_name)
    end
    it 'contains the list of values of the record (expcept :lock_version)' do
      # required_attributes = record.attributes.reject{ |key| key == 'lock_version' }
      required_attributes = record.attributes.reject { |key| to_ignore.include?(key) }
      quoted_values       = required_attributes.values.map { |value| record.class.connection.quote(value) }
      sql_text            = subject.to_sql_insert(record)
      expect(sql_text).to include(quoted_values.join(', '))
    end
  end

  describe '#to_sql_update' do
    it 'returns a String' do
      expect(subject.to_sql_update(record)).to be_an_instance_of(String)
    end
    it 'contains the table name' do
      sql_text = subject.to_sql_update(record)
      expect(sql_text).to include(record.class.table_name)
    end
    it 'contains the list of values of the record (expcept :id & :lock_version)' do
      # required_attributes = record.attributes.reject{ |key| key == 'id' || key == 'lock_version' }
      required_attributes = record.attributes.reject { |key| key == 'id' || to_ignore.include?(key) }
      quoted_values       = required_attributes.values.map { |value| record.class.connection.quote(value) }
      sql_text            = subject.to_sql_update(record)
      quoted_values.each do |value|
        expect(sql_text).to include(value)
      end
    end
  end

  describe '#to_sql_delete' do
    it 'returns a String' do
      expect(subject.to_sql_delete(record)).to be_an_instance_of(String)
    end
    it 'contains the table name' do
      sql_text = subject.to_sql_delete(record)
      expect(sql_text).to include(record.class.table_name)
    end
    it 'contains the ID value of the record' do
      sql_text = subject.to_sql_delete(record)
      expect(sql_text).to include(record.id.to_s)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
