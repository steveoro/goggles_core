# frozen_string_literal: true

require 'date'
require 'ffaker'

require 'common/validation_error_tools'

FactoryBot.define do
  factory :fin_calendar do
    season_id             { Season.find([162, 152, 142, 132, 122, 112].sample).id }
    calendar_year         { season.begin_date.year.to_s }
    calendar_month        { FFaker::Time.month }
    calendar_date         { FFaker::Time.date }
    calendar_place        { City.where('LENGTH(name) > 3').sample.name }
    calendar_name         { "#{(rand * 10).to_i + 1}° Trofeo #{FFaker::Lorem.word.camelcase} di #{calendar_place}" }
    manifest_link         nil
    startlist_link        nil
    results_link          nil

    fin_manifest_code     nil
    fin_startlist_code    nil
    fin_results_code      nil
    # Since we don't have the NameNormalizer strategy available here, we use an
    # approximation of it:
    goggles_meeting_code  { calendar_place.gsub(%r{[\s\-\_\'`\\/\:\.\,\;]}, '').downcase }

    user_id               { 1 }

    before(:create) do |built_instance|
      if built_instance.invalid?
        # puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for( built_instance )
        puts built_instance.inspect
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
