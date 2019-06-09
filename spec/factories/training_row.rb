# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  trait :training_detail do
    # The following columns use the pre-loaded seed records:
    exercise_id               { ((rand * 1000) % 196).to_i + 1 }
    training_step_type_id     { ((rand * 10) % 5).to_i + 1 }
    arm_aux_type_id           { ((rand * 10) % 4).to_i + 1 }
    kick_aux_type_id          { ((rand * 10) % 6).to_i + 1 }
    body_aux_type_id          { ((rand * 10) % 6).to_i + 1 }
    breath_aux_type_id        { ((rand * 10) % 2).to_i + 1 }

    group_id                  { ((rand * 10) % 4).to_i + 1 }
    group_times               { ((rand * 10) % 5).to_i + 1 }
    group_start_and_rest      { 0 }
    group_pause               { (((rand * 10) % 5).to_i + 1) * 5 }
    sequence(:part_order)
    times                     { ((rand * 10) % 8).to_i + 1 }
    distance                  { (((rand * 10) % 4).to_i + 1) * 50 }
    start_and_rest            { (((rand * 10) % 5).to_i + 1) * 5 }
    pause                     { (((rand * 10) % 5).to_i + 1) * 5 }
  end
  #-- -------------------------------------------------------------------------
  #++

  factory :training_row do
    training_detail
    training
  end
  #-- -------------------------------------------------------------------------
  #++
end
