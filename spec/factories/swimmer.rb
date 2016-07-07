require 'date'
require 'ffaker'

require 'common/validation_error_tools'


FactoryGirl.define do

  trait :common_swimmer_fields do
    first_name                { FFaker::Name.first_name }
    last_name                 { FFaker::Name.last_name }
    gender_type               { GenderType.individual_only.sample }
    year_of_birth             { 18.year.ago.year - ((rand * 100) % 60).to_i } # was Date.today.year -
    complete_name             { "#{last_name} #{first_name}" }
    user
  end
  #-- -------------------------------------------------------------------------
  #++


  factory :swimmer do
    common_swimmer_fields
    fake_phone_numbers
    e_mail                    { FFaker::Internet.email }
    nickname                  { FFaker::Internet.user_name  }
    associated_user_id        nil

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for( built_instance )
        puts built_instance.inspect
      end
    end

    factory :swimmer_with_results do
      after(:create) do |created_instance, evaluator|
        meeting_individual_result = create_list(
          :meeting_individual_result_with_passages,
          ((rand * 10).to_i + 2),                   # total number of results
          swimmer: created_instance                 # association enforce for each sub-row
        )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
