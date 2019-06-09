# frozen_string_literal: true

require 'rails_helper'

describe DataImportMeetingEntry, type: :model do
  it_behaves_like 'SwimmerRelatable'
  it_behaves_like 'TimingGettable'
  #-- -------------------------------------------------------------------------
  #++

  context '[a well formed instance]' do
    # This will have a link to a :data_import_meeting_program_individual
    subject { create(:data_import_meeting_entry) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:data_import_meeting_program, :swimmer, :team, :team_affiliation, :badge])

    context '[general methods]' do
      it_behaves_like('(the existance of a method returning non-empty strings)', [:get_full_name, :get_verbose_name])
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
