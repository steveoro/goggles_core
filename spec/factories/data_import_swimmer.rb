require 'date'
require 'ffaker'


FactoryGirl.define do

  factory :data_import_swimmer do
    data_import_session
    conflicting_id        nil
    common_swimmer_fields
    import_text               { "#{year_of_birth} #{complete_name}" }
  end
  #-- -------------------------------------------------------------------------
  #++
end
