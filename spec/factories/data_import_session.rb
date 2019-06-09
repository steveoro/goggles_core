# frozen_string_literal: true

require 'ffaker'

FactoryBot.define do
  factory :data_import_session do
    file_name               { "ris#{(season.begin_date + 60.days).strftime('%Y%m%d')}#{FFaker::Internet.domain_word}.txt" }
    source_data             { FFaker::Lorem.paragraph[0..250] }
    phase                   0
    total_data_rows         0
    season
    user_id                 1
    file_format             { FFaker::Lorem.word.camelcase }
    phase_1_log             { FFaker::Lorem.paragraph[0..250] }
    phase_2_log             { FFaker::Lorem.paragraph[0..250] }
    phase_3_log             { FFaker::Lorem.paragraph[0..250] }
    data_import_season_id   nil
  end
  #-- -------------------------------------------------------------------------
  #++
end
