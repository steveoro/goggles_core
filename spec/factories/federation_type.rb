require 'date'
require 'ffaker'


FactoryBot.define do

  factory :federation_type do
    sequence( :code )         { |n| "F#{n}" }
    description               { "Fake #{ FFaker::Lorem.word.camelcase } Swimming Federation" }
    short_name                { "FSF#{code}" }
  end
  #-- -------------------------------------------------------------------------
  #++
end
