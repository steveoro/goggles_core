require 'ffaker'

FactoryGirl.define do
  factory :area_type do
    code        { "@{FFaker::String}"[0..2] }
    name        { FFaker::Lorem.word }
    
    region_type
  end
end
