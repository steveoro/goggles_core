# frozen_string_literal: true

require 'rails_helper'

describe DataImportPassage, type: :model do
  it_behaves_like 'SwimmerRelatable'
  it_behaves_like 'TimingGettable'
  #-- -------------------------------------------------------------------------
  #++

  context '[a well formed instance]' do
    subject { create(:data_import_passage) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:passage_type, :meeting_program, :meeting_individual_result, :swimmer, :team])
  end
  #-- -------------------------------------------------------------------------
  #++
end
