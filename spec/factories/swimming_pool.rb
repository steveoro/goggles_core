# frozen_string_literal: true

require 'ffaker'

FactoryBot.define do
  factory :swimming_pool do
    name                    { "#{FFaker::Address.street_name} pool" }
    nick_name               { FFaker::Address.street_name.downcase.gsub(' ', '') }
    address                 { FFaker::Address.street_address }
    lanes_number            { 6 + 2 * ((rand * 10) % 3).to_i }
    has_multiple_pools      { (rand * 100).to_i.even? }
    has_open_area           { (rand * 100).to_i.even? }
    has_bar                 { (rand * 100).to_i.even? }
    has_restaurant_service  { (rand * 100).to_i.even? }
    has_gym_area            { (rand * 100).to_i.even? }
    has_children_area       { (rand * 100).to_i.even? }
    # pool_type_id            { PoolType.only_for_meetings[(rand * (PoolType.only_for_meetings.count - 1)).round(0)].id }
    pool_type_id            { PoolType.only_for_meetings.sample.id }

    city
    user
  end
  #-- -------------------------------------------------------------------------
  #++
end
