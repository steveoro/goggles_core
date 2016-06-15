require 'date'
require 'ffaker'

require 'common/validation_error_tools'


FactoryGirl.define do

  trait :fake_phone_numbers do
    phone_mobile              { FFaker::PhoneNumber.phone_number }
    phone_number              { FFaker::PhoneNumber.phone_number }
  end
  #-- -------------------------------------------------------------------------
  #++


  factory :data_import_team do
    data_import_session
    city
    name                      { "#{city.name} Swimming Club ASD" }
    import_text               { name }
    data_import_city          nil
    badge_number              nil
    user
  end


  factory :team do
    city
    name                      { "#{city.name} Swimming Club ASD" }
    editable_name             { name }
    address                   { FFaker::Address.street_address }
    fake_phone_numbers
    e_mail                    { FFaker::Internet.email }
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
