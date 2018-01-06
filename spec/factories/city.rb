require 'ffaker'


FactoryBot.define do

  trait :random_city do
    name                    { FFaker::Address.city }
    zip                     { FFaker::AddressFR.postal_code }
    area                    { FFaker::AddressUS.state }
    country                 { FFaker::Address.country }
    country_code            { FFaker::Address.country_code }

    area_type do
      if AreaType.count > 0
        AreaType.all.sort{rand - 0.5}.first
      else
        create(:area_type)
      end
    end
  end


  factory :city do
    random_city

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for( built_instance )
        puts built_instance.inspect
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
