# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  factory :user_training do
    training_header

    factory :user_training_with_rows do
      after(:create) do |created_instance, _evaluator|
        create_list(
          :user_training_row,
          ((rand * 10).to_i + 2),                   # total number or detail rows
          user_training: created_instance           # association enforce for each sub-row
        )
      end
    end

    factory :invalid_user_training do
      description nil
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
