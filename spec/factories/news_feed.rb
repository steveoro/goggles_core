# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  factory :news_feed do
    sequence(:title) { |n| "Something happened n.#{n}" }
    body                  { "Something happened! #{(rand * 100).to_i} friends got interested in you, but then cancelled their requests!" }
    is_read               false
    is_friend_activity    { (rand * 100).to_i.even? }
    is_achievement        { (rand * 100).to_i.even? }
    user
    association :friend, factory: :user
  end
  #-- -------------------------------------------------------------------------
  #++
end
