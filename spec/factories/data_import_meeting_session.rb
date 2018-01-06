require 'date'
require 'ffaker'


FactoryBot.define do

  factory :data_import_meeting_session do
    data_import_session
    conflicting_id            nil
    import_text               { FFaker::Lorem.paragraph[0..250] }
    data_import_meeting_id    nil
    common_meeting_session_fields
  end
  #-- -------------------------------------------------------------------------
  #++
end
