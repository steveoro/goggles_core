# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  trait :training_header do
    sequence(:description) { |n| "#{FFaker::Lorem.word} workout n.#{n}" }
    user
  end
  #-- -------------------------------------------------------------------------
  #++

  factory :training do
    sequence(:title) { |n| "Workout model n.#{n}" }
    training_header

    # user_training_with_rows will create detail data after the user_training has been created
    factory :training_with_rows do
      # the after(:create) yields two values: the row instance itself and the
      # evaluator, which stores all values from the factory, including transient
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the association is set properly to the created instance:
      after(:create) do |created_instance, _evaluator|
        create_list(
          :training_row,
          ((rand * 10).to_i + 2),                   # total number or detail rows
          training: created_instance                # association enforce for each sub-row
        )
      end
    end

    factory :training_with_grouped_rows do
      after(:create) do |created_instance, _evaluator|
        create(:training_row, training: created_instance, part_order: 1)
        create(:training_row, training: created_instance, part_order: 2, group_id: 1, group_times: 5)
        create(:training_row, training: created_instance, part_order: 3, group_id: 1)
        create(:training_row, training: created_instance, part_order: 4)
      end
    end

    factory :invalid_training do
      description nil
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
