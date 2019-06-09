# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :team_manager do
    team_affiliation
    user
  end
  #-- -------------------------------------------------------------------------
  #++
end
