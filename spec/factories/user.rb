# frozen_string_literal: true

require 'date'
require 'ffaker'

FactoryBot.define do
  factory :user do
    name                      { "#{FFaker::Internet.user_name}-#{(rand * 1000).to_i}" }
    email                     { FFaker::Internet.email }
    description               { "#{FFaker::Name.first_name} #{FFaker::Name.last_name}" }
    password                  { 'password' }
    password_confirmation     { 'password' }
    confirmed_at              { Time.zone.now }
    created_at                { Time.zone.now }
    updated_at                { Time.zone.now }
    swimmer_level_type_id     { ((rand * 100) % 15).to_i + 1 } # ASSERT: there exists at least 14 rows for this entity in test DB
  end
  #-- -------------------------------------------------------------------------
  #++
end
