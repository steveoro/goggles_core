# frozen_string_literal: true

require 'date'
require 'ffaker'

require 'common/validation_error_tools'

FactoryBot.define do
  factory :computed_season_ranking do
    season
    team
    rank                      { (((rand * 10) % 3).to_i + 1) }
    total_points              { ((rand * 5000).to_i + 1) }

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
