# frozen_string_literal: true

require 'date'
require 'ffaker'

require 'common/validation_error_tools'

FactoryBot.define do
  factory :category_type do
    age_begin                 { ((((rand * 100) % 15).to_i * 5) + 25) }
    age_end                   { age_begin ? age_begin + 5 : 99 }
    code                      { "M#{age_begin || 25}" }
    description               { "MASTER #{age_begin || 25}" }
    short_name                { code }
    season
    # group_name
    federation_code           { (rand * 100).to_i.to_s } # (This has nothing to do with season.federation_type.code)
    is_a_relay                { false }
    is_out_of_race            { false }

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for(built_instance)
        puts built_instance.inspect
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
