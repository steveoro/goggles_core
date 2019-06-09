# frozen_string_literal: true

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :data_import_swimmer_analysis_result do
    data_import_session
    analysis_log_text         { FFaker::Lorem.paragraph[0..128] }
    sql_text                  ''

    chosen_swimmer_id         nil
    desired_year_of_birth     1900
    max_year_of_birth         nil
    desired_gender_type_id    nil
    searched_swimmer_name     nil
    category_type

    match_name                nil
    match_score               9.9
    best_match_name           nil
    best_match_score          9.9

    after(:create) do |created_instance, _evaluator|
      swimmer = create(:swimmer)
      created_instance.chosen_swimmer_id      = swimmer.id
      created_instance.searched_swimmer_name  = swimmer.complete_name
      created_instance.match_name             = swimmer.complete_name
      created_instance.best_match_name        = swimmer.complete_name
      created_instance.desired_year_of_birth  = swimmer.year_of_birth
      created_instance.desired_gender_type_id = swimmer.gender_type_id
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
