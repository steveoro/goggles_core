require 'ffaker'

FactoryGirl.define do
  factory :nation_type do
    code         "ITA"
    numeric_code "001"
    alpha2_code  "IT"
  end
end
