# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  factory :user_achievement do
    user
    achievement { Achievement.all.min { rand - 0.5 } }
  end
  #-- -------------------------------------------------------------------------
  #++
end
