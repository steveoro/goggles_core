require 'ffaker'


FactoryGirl.define do

  factory :data_import_city do
    data_import_session
    conflicting_id        nil
    import_text           { FFaker::Lorem.paragraph[0..100] }
    name                    { FFaker::Address.city }
    zip                     { FFaker::AddressFR.postal_code }
    area                    { FFaker::AddressUS.state }
    country                 { FFaker::Address.country }
    country_code            { FFaker::Address.country_code }
    user

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
