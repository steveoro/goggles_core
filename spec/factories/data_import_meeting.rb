require 'date'
require 'ffaker'


FactoryBot.define do

  factory :data_import_meeting do
    data_import_session
    conflicting_id            nil
    import_text               { FFaker::Lorem.paragraph[0..200] }

    sequence( :code )         { |n| "meeting#(n)" }
    description               { "#{FFaker::Name.suffix} #{FFaker::Address.city} Meeting" }

    edition                   { ((rand * 100) % 40).to_i }
    season                    { data_import_session.season }
    header_date               { season.begin_date + (rand * 100).to_i.days }
    header_year               { season.header_year }
    # The following 2 columns use the pre-loaded seed records:
    edition_type_id           { ((rand * 100) % 5).to_i + 1 } # ASSERT: at least 5 edition types (1..5)
    timing_type_id            { ((rand * 100) % 3).to_i + 1 } # ASSERT: at least 3 timing types (1..3)
    user
  end
  #-- -------------------------------------------------------------------------
  #++
end
