# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  factory :article do
    sequence(:title) { |n| "Great dummy article title n.#{n}" }
    body                  { "#{FFaker::Lorem.paragraph}\r\n#{FFaker::Lorem.paragraph}" }
    is_sticky             { (rand * 100).to_i.even? }
    user
  end
  #-- -------------------------------------------------------------------------
  #++
end
