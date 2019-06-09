# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  factory :user_training_story do
    swam_date                 { Date.today }
    total_training_time       { 65 }
    notes                     { "Dude, that was hard!\r\n#{FFaker::Lorem.paragraph}" }
    user
    user_training
    swimming_pool
    swimmer_level_type_id { ((rand * 100) % 15).to_i }

    factory :invalid_user_training_story do
      swam_date { nil }
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
