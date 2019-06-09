# frozen_string_literal: true

require 'rails_helper'

describe DataImportCity, type: :model do
  # TODO
  # describe "[a non-valid instance]" do
  # it_behaves_like( "(missing required values)", [ :number ])
  # end
  #-- -------------------------------------------------------------------------
  #++

  context '[a well formed instance]' do
    subject { create(:data_import_city) }

    it 'is a valid istance' do
      expect(subject).to be_valid
    end
    # TODO
    # Validated relations:
    # it_behaves_like( "(belongs_to required models)", [
    # :team,
    # :season,
    # :swimmer,
    # :category_type,
    # :entry_time_type
    # ])
  end
  #-- -------------------------------------------------------------------------
  #++
end
