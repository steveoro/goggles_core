require 'ffaker'


FactoryGirl.define do

  trait :random_city do
    name                    { FFaker::Address.city }
    zip                     { FFaker::AddressFR.postal_code }
    area                    { FFaker::AddressUS.state }
    country                 { FFaker::Address.country }
    country_code            { FFaker::Address.country_code }
    
    area_type
  end

  factory :city do
    random_city
  end
  #-- -------------------------------------------------------------------------
  #++
end
