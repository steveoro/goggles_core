# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  factory :data_import_team do
    data_import_session
    city
    name                      { "#{city.name} Swimming Club ASD" }
    import_text               { name }
    data_import_city          { nil }
    badge_number              { nil }
    user
  end
  #-- -------------------------------------------------------------------------
  #++
end
