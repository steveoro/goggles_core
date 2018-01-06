require 'date'
require 'ffaker'


FactoryBot.define do

  factory :season_type do
    # Code has a unique index on season_type, so we must use a sequence here:
    sequence( :code )         { |n| "MAS#{federation_type.code}-#{n}" }
    # Using a seed/fixture like this seems to yield to random validation errors:
    # federation_type { FederationType.all.sort{ rand - 0.5 }[0] }
    # Let's use a completely random Federation:
    federation_type
    description               { "MASTER #{federation_type.code} #{ FFaker::Lorem.word.upcase }"[0..99] }
    short_name                { "MASTER #{federation_type.code}"[0..39] }
  end
  #-- -------------------------------------------------------------------------
  #++
end
