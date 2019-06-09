# frozen_string_literal: true

require 'rails_helper'
require 'date'

describe DataImportMeeting, type: :model do
  context '[a well formed instance]' do
    subject { create(:data_import_meeting) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # Validated relations:
    it_behaves_like('(belongs_to required models)', [:edition_type, :timing_type])

    context '[general methods]' do
      it_behaves_like('(the existance of a method returning non-empty and non-? strings)', [:get_short_name, :get_full_name, :get_verbose_name])
      it_behaves_like('(the existance of a method returning non-empty strings)', [
                        :get_season_type
                      ])
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
