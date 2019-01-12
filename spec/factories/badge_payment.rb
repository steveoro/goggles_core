require 'date'
require 'ffaker'


FactoryBot.define do

  factory :badge_payment do
    badge                 Team.find(1).swimmers.sample.badges.sample
    payment_date          Date.current
    amount                12.00
    is_manual             false
    sequence( :notes )    { |n| "Badge payment n.#{n}" }
    user
  end
  #-- -------------------------------------------------------------------------
  #++
end
