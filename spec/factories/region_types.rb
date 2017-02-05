require 'ffaker'

FactoryGirl.define do
  factory :region_type do
    code { "@{FFaker::String}"[0..2] }
    name { FFaker::Lorem.word }
  end
end
