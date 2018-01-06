require 'date'
require 'ffaker'


FactoryBot.define do

  factory :user_achievement do
    user
    achievement       { Achievement.all.sort{ rand - 0.5 }[0] }
  end
  #-- -------------------------------------------------------------------------
  #++
end
