require 'date'
require 'ffaker'


FactoryBot.define do

  factory :data_import_badge do
    data_import_session
    common_badge_fields
    season                    { data_import_session.season }
    category_type             { create(:category_type, season: season) }
    data_import_swimmer_id    nil
    data_import_team_id       nil
    data_import_season_id     nil

    swimmer do                # This will create a swimmer coherent with the category of the badge:
      swimmer_year = category_type.season.begin_date.year - category_type.age_end
      create( :swimmer, year_of_birth: swimmer_year )
    end

    import_text               { number }
  end
  #-- -------------------------------------------------------------------------
  #++
end
