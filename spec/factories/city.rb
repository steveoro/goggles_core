require 'ffaker'


FactoryGirl.define do

  trait :random_city do
    name                    { FFaker::Address.city }
    zip                     { FFaker::AddressFR.postal_code }
    area                    { FFaker::AddressUS.state }
    country                 { FFaker::Address.country }
    country_code            { FFaker::Address.country_code }
  end


  factory :city do
    random_city
  end

  factory :data_import_city do
    data_import_session
    conflicting_id        nil
    import_text           { FFaker::Lorem.paragraph[0..100] }
    random_city
    user
  end
  #-- -------------------------------------------------------------------------
  #++
end
