# frozen_string_literal: true

require 'date'
require 'ffaker'

require 'common/validation_error_tools'

FactoryBot.define do
  factory :goggle_cup do
    description { "#{FFaker::Name.suffix} #{FFaker::Address.city} Fun Cup" }
    team
    season_year               { ((rand * 100) % 10).to_i + 2007 }
    max_points                1000
    max_performance           { ((rand * 100) % 5).to_i + 3 }
    end_date                  { Date.parse("#{season_year}0731") }
    user

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for(built_instance)
        puts built_instance.inspect
      end
    end

    factory :goggle_cup_with_definitions do
      after(:create) do |created_instance, _evaluator|
        create_list(
          :goggle_cup_definition,
          ((rand * 3).to_i + 1),               # total number of seasons
          goggle_cup: created_instance         # association enforce for each sub-row
        )
      end
    end

    factory :goggle_cup_with_standards do
      after(:create) do |created_instance, _evaluator|
        create_list(
          :goggle_cup_standard,
          ((rand * 30).to_i + 1),              # total number of standard times
          goggle_cup: created_instance         # association enforce for each sub-row
        )
      end
    end

    factory :goggle_cup_complete do
      after(:create) do |created_instance, _evaluator|
        create_list(
          :goggle_cup_standard,
          ((rand * 30).to_i + 1),              # total number of results
          goggle_cup: created_instance         # association enforce for each sub-row
        )
        create_list(
          :goggle_cup_definition,
          ((rand * 3).to_i + 1),               # total number of seasons
          goggle_cup: created_instance         # association enforce for each sub-row
        )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
