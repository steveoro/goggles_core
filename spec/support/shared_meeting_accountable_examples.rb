# frozen_string_literal: true

require 'rails_helper'

shared_examples_for 'MeetingAccountable' do |team_id, tot_male_results, tot_female_results, tot_team_results, tot_male_entries, tot_female_entries, tot_team_entries|
  # Describes the requistes of the including class
  # and the outcome of the module inclusion.
  #
  context 'by including this concern' do
    it_behaves_like('(the existance of a method returning numeric values)',
                    [:count_results, :count_entries])
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#count_results' do
    it 'returns the total results count with a nil parameter which uses the whole scope' do
      expect(subject.count_results).to eq(tot_male_results + tot_female_results)
    end
    it 'returns the total male results count with a scope Proc parameter' do
      expect(subject.count_results(&:is_male)).to eq(tot_male_results)
    end
    it 'returns the total female results count with a scope Proc parameter' do
      expect(subject.count_results(&:is_female)).to eq(tot_female_results)
    end
    it 'returns a filtered result count with a scope block parameter' do
      expect( # Filter a single team:
        subject.count_results { |rel| rel.where(team_id: team_id) }
      ).to eq(tot_team_results)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe '#count_entries' do
    it 'returns the total entries count with a nil parameter which uses the whole scope' do
      expect(subject.count_entries).to eq(tot_male_entries + tot_female_entries)
    end
    it 'returns the total male entries count with a scope Proc parameter' do
      expect(subject.count_entries(&:is_male)).to eq(tot_male_entries)
    end
    it 'returns the total female entries count with a scope Proc parameter' do
      expect(subject.count_entries(&:is_female)).to eq(tot_female_entries)
    end
    it 'returns a filtered entries count with a scope block parameter' do
      expect( # Filter a single team:
        subject.count_entries { |rel| rel.where(team_id: team_id) }
      ).to eq(tot_team_entries)
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
