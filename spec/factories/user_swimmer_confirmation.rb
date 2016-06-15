require 'date'
require 'ffaker'


FactoryGirl.define do

  factory :user_swimmer_confirmation do
    user
    swimmer
    association :confirmator, factory: :user
  end
  #-- -------------------------------------------------------------------------
  #++
end
