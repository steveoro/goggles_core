require 'date'
require 'ffaker'


FactoryBot.define do

  factory :user_swimmer_confirmation do
    user
    swimmer
    association :confirmator, factory: :user
  end
  #-- -------------------------------------------------------------------------
  #++
end
