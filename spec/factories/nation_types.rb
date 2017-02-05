require 'ffaker'

FactoryGirl.define do
  factory :nation_type do
    code         { "@{FFaker::String}"[0..2] }
    numeric_code ''
    alpha2_code  ''
  end
end
