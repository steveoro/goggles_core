# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190213194658) do

  create_table "achievement_rows", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "part_order", limit: 3, default: 0
    t.string "achievement_value", limit: 10
    t.boolean "is_bracket_open", default: false
    t.boolean "is_or_operator", default: false
    t.boolean "is_not_operator", default: false
    t.boolean "is_bracket_closed", default: false
    t.integer "achievement_id"
    t.integer "achievement_type_id"
    t.index ["achievement_id"], name: "idx_achievement_rows_achievement"
    t.index ["achievement_type_id"], name: "idx_achievement_rows_achievement_type"
  end

  create_table "achievement_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_achievement_types_on_code", unique: true
  end

  create_table "achievements", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 10
    t.integer "user_id"
    t.index ["code"], name: "index_achievements_on_code", unique: true
  end

  create_table "admins", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", default: ""
    t.string "encrypted_password", default: ""
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    t.integer "lock_version", default: 0
    t.string "name"
    t.string "description", limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["name"], name: "index_admins_on_name", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "app_parameters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.integer "code"
    t.string "controller_name"
    t.string "action_name"
    t.boolean "is_a_post", default: false
    t.string "confirmation_text"
    t.string "a_string"
    t.boolean "a_bool"
    t.integer "a_integer"
    t.datetime "a_date"
    t.decimal "a_decimal", precision: 10, scale: 2
    t.decimal "a_decimal_2", precision: 10, scale: 2
    t.decimal "a_decimal_3", precision: 10, scale: 2
    t.decimal "a_decimal_4", precision: 10, scale: 2
    t.bigint "range_x"
    t.bigint "range_y"
    t.string "a_name"
    t.string "a_filename"
    t.string "tooltip_text"
    t.integer "view_height", default: 0
    t.bigint "code_type_1"
    t.bigint "code_type_2"
    t.bigint "code_type_3"
    t.bigint "code_type_4"
    t.text "free_text_1"
    t.text "free_text_2"
    t.text "free_text_3"
    t.text "free_text_4"
    t.boolean "free_bool_1"
    t.boolean "free_bool_2"
    t.boolean "free_bool_3"
    t.boolean "free_bool_4"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_app_parameters_on_code", unique: true
  end

  create_table "area_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 10
    t.string "name"
    t.integer "region_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_area_types_on_code"
    t.index ["region_type_id", "code"], name: "index_area_types_region_code"
    t.index ["region_type_id"], name: "index_area_types_on_region_type_id"
  end

  create_table "arm_aux_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_arm_aux_types_on_code", unique: true
  end

  create_table "articles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "title", limit: 80
    t.text "body"
    t.boolean "is_sticky", default: false
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["title"], name: "index_articles_on_title"
    t.index ["user_id"], name: "idx_articles_user"
  end

  create_table "badge_payments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.decimal "amount", precision: 10, scale: 2
    t.date "payment_date"
    t.text "notes"
    t.boolean "is_manual"
    t.bigint "badge_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_badge_payments_on_badge_id"
    t.index ["user_id"], name: "index_badge_payments_on_user_id"
  end

  create_table "badges", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "number", limit: 40
    t.integer "season_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "category_type_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "entry_time_type_id"
    t.integer "team_affiliation_id"
    t.integer "final_rank"
    t.boolean "is_out_of_goggle_cup", default: false
    t.boolean "has_to_pay_fees", default: false, null: false
    t.boolean "has_to_pay_badge", default: false, null: false
    t.boolean "has_to_pay_relays", default: false, null: false
    t.index ["category_type_id"], name: "fk_badges_category_types"
    t.index ["entry_time_type_id"], name: "fk_badges_entry_time_types"
    t.index ["number"], name: "index_badges_on_number"
    t.index ["season_id"], name: "fk_badges_seasons"
    t.index ["swimmer_id"], name: "fk_badges_swimmers"
    t.index ["team_affiliation_id"], name: "fk_badges_team_affiliations"
    t.index ["team_id"], name: "fk_badges_teams"
    t.index ["user_id"], name: "idx_badges_user"
  end

  create_table "base_movements", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 6
    t.boolean "is_arm_aux_allowed", default: false
    t.boolean "is_kick_aux_allowed", default: false
    t.boolean "is_body_aux_allowed", default: false
    t.boolean "is_breath_aux_allowed", default: false
    t.integer "movement_type_id"
    t.integer "stroke_type_id"
    t.integer "movement_scope_type_id"
    t.integer "user_id"
    t.index ["code"], name: "index_base_movements_on_code", unique: true
    t.index ["movement_scope_type_id"], name: "fk_base_movements_movement_scope_types"
    t.index ["movement_type_id"], name: "fk_base_movements_movement_types"
    t.index ["stroke_type_id"], name: "fk_base_movements_stroke_types"
    t.index ["user_id"], name: "idx_base_movements_user"
  end

  create_table "body_aux_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_body_aux_types_on_code", unique: true
  end

  create_table "breath_aux_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_breath_aux_types_on_code", unique: true
  end

  create_table "category_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 7
    t.string "federation_code", limit: 2
    t.string "description", limit: 100
    t.string "short_name", limit: 50
    t.string "group_name", limit: 50
    t.integer "age_begin", limit: 3
    t.integer "age_end", limit: 3
    t.boolean "is_a_relay", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "season_id"
    t.boolean "is_out_of_race", default: false
    t.boolean "is_undivided", default: false, null: false
    t.index ["federation_code", "is_a_relay"], name: "federation_code"
    t.index ["season_id", "is_a_relay", "code"], name: "season_and_code", unique: true
  end

  create_table "cities", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "name", limit: 50
    t.string "zip", limit: 6
    t.string "area", limit: 50
    t.string "country", limit: 50
    t.string "country_code", limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "area_type_id"
    t.index ["area_type_id"], name: "index_cities_on_area_type_id"
    t.index ["name"], name: "index_cities_on_name"
    t.index ["user_id"], name: "idx_cities_user"
    t.index ["zip"], name: "index_cities_on_zip"
  end

  create_table "coach_level_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.integer "level", limit: 3, default: 0
    t.index ["code"], name: "index_coach_level_types_on_code", unique: true
  end

  create_table "comments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "entry_text"
    t.integer "user_id"
    t.integer "swimming_pool_review_id"
    t.integer "comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["comment_id"], name: "fk_comments_comments"
    t.index ["swimming_pool_review_id"], name: "fk_comments_swimming_pool_reviews"
    t.index ["user_id"], name: "idx_comments_user"
  end

  create_table "computed_season_rankings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rank", default: 0
    t.decimal "total_points", precision: 10, scale: 2, default: "0.0"
    t.integer "team_id"
    t.integer "season_id"
    t.index ["season_id", "rank"], name: "rank_x_season"
    t.index ["season_id", "team_id"], name: "teams_x_season"
    t.index ["team_id"], name: "fk_computed_season_rankings_teams"
  end

  create_table "data_import_badges", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.string "number", limit: 40
    t.integer "data_import_swimmer_id"
    t.integer "data_import_team_id"
    t.integer "data_import_season_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "season_id"
    t.integer "category_type_id"
    t.integer "user_id"
    t.integer "entry_time_type_id"
    t.integer "team_affiliation_id"
    t.index ["category_type_id"], name: "idx_di_badges_category_type"
    t.index ["data_import_season_id"], name: "idx_di_badges_di_season"
    t.index ["data_import_session_id"], name: "idx_di_badges_di_session"
    t.index ["data_import_swimmer_id"], name: "idx_di_badges_di_swimmer"
    t.index ["data_import_team_id"], name: "idx_di_badges_di_team"
    t.index ["entry_time_type_id"], name: "idx_di_badges_entry_time_type"
    t.index ["number"], name: "index_data_import_badges_on_number"
    t.index ["season_id"], name: "idx_di_badges_season"
    t.index ["swimmer_id"], name: "idx_di_badges_swimmer"
    t.index ["team_affiliation_id"], name: "idx_di_badges_team_affiliation"
    t.index ["team_id"], name: "idx_di_badges_team"
    t.index ["user_id"], name: "idx_di_badges_user"
  end

  create_table "data_import_cities", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.string "name", limit: 50
    t.string "zip", limit: 6
    t.string "area", limit: 50
    t.string "country", limit: 50
    t.string "country_code", limit: 10
    t.integer "user_id"
    t.index ["data_import_session_id"], name: "idx_di_cities_di_session"
    t.index ["name"], name: "index_data_import_cities_on_name"
    t.index ["user_id"], name: "idx_di_cities_user"
    t.index ["zip"], name: "index_data_import_cities_on_zip"
  end

  create_table "data_import_meeting_entries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.string "athlete_name", limit: 100
    t.string "team_name", limit: 60
    t.string "athlete_badge_number", limit: 40
    t.string "team_badge_number", limit: 40
    t.integer "year_of_birth", default: 1900
    t.integer "minutes", limit: 3
    t.integer "seconds", limit: 2
    t.integer "hundreds", limit: 2
    t.boolean "is_no_time", default: false
    t.integer "start_list_number"
    t.integer "lane_number", limit: 2
    t.integer "heat_number"
    t.integer "heat_arrival_order", limit: 2
    t.integer "data_import_meeting_program_id"
    t.integer "data_import_swimmer_id"
    t.integer "data_import_team_id"
    t.integer "data_import_badge_id"
    t.integer "meeting_program_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "team_affiliation_id"
    t.integer "badge_id"
    t.integer "entry_time_type_id"
    t.integer "user_id"
    t.index ["badge_id"], name: "idx_di_meeting_entries_badge"
    t.index ["data_import_badge_id"], name: "idx_di_meeting_entries_di_badge"
    t.index ["data_import_meeting_program_id"], name: "idx_di_meeting_entries_di_meeting_program"
    t.index ["data_import_session_id"], name: "idx_di_meeting_entries_di_session"
    t.index ["data_import_swimmer_id"], name: "idx_di_meeting_entries_di_swimmer"
    t.index ["data_import_team_id"], name: "idx_di_meeting_entries_di_team"
    t.index ["entry_time_type_id"], name: "idx_di_meeting_entries_entry_time_type"
    t.index ["meeting_program_id"], name: "idx_di_meeting_entries_meeting_program"
    t.index ["swimmer_id"], name: "idx_di_meeting_entries_swimmer"
    t.index ["team_affiliation_id"], name: "idx_di_meeting_entries_team_affiliation"
    t.index ["team_id"], name: "idx_di_meeting_entries_team"
    t.index ["user_id"], name: "idx_di_meeting_entries_user"
  end

  create_table "data_import_meeting_individual_results", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.string "athlete_name", limit: 100
    t.string "team_name", limit: 60
    t.string "athlete_badge_number", limit: 40
    t.string "team_badge_number", limit: 40
    t.integer "year_of_birth", default: 1900
    t.integer "rank", default: 0
    t.boolean "is_play_off", default: false
    t.boolean "is_out_of_race", default: false
    t.boolean "is_disqualified", default: false
    t.decimal "standard_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_individual_points", precision: 10, scale: 2, default: "0.0"
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundreds", limit: 2, default: 0
    t.integer "data_import_meeting_program_id"
    t.integer "meeting_program_id"
    t.integer "data_import_swimmer_id"
    t.integer "data_import_team_id"
    t.integer "data_import_badge_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "badge_id"
    t.integer "user_id"
    t.integer "disqualification_code_type_id"
    t.decimal "goggle_cup_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "reaction_time", precision: 5, scale: 2, default: "0.0"
    t.decimal "team_points", precision: 10, scale: 2, default: "0.0"
    t.integer "team_affiliation_id"
    t.index ["badge_id"], name: "idx_di_mir_badge"
    t.index ["data_import_badge_id"], name: "idx_di_mir_di_badge"
    t.index ["data_import_meeting_program_id"], name: "idx_di_mir_di_meeting_program"
    t.index ["data_import_session_id"], name: "idx_di_mir_di_session"
    t.index ["data_import_swimmer_id"], name: "idx_di_mir_di_swimmer"
    t.index ["data_import_team_id"], name: "idx_di_mir_di_team"
    t.index ["disqualification_code_type_id"], name: "idx_di_mir_disqualification_code_type"
    t.index ["meeting_program_id"], name: "idx_di_mir_meeting_program"
    t.index ["swimmer_id"], name: "idx_di_mir_swimmer"
    t.index ["team_affiliation_id"], name: "idx_di_mir_team_affiliation"
    t.index ["team_id"], name: "idx_di_mir_team"
    t.index ["user_id"], name: "idx_di_mir_user"
  end

  create_table "data_import_meeting_programs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.integer "event_order", limit: 3, default: 0
    t.time "begin_time"
    t.integer "data_import_meeting_session_id"
    t.integer "meeting_session_id"
    t.integer "event_type_id"
    t.integer "category_type_id"
    t.integer "gender_type_id"
    t.integer "user_id"
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundreds", limit: 2, default: 0
    t.boolean "is_out_of_race", default: false
    t.integer "heat_type_id"
    t.integer "time_standard_id"
    t.index ["data_import_meeting_session_id"], name: "idx_di_meeting_programs_di_meeting_session"
    t.index ["data_import_session_id"], name: "idx_di_meeting_programs_di_session"
    t.index ["heat_type_id"], name: "idx_di_meeting_programs_heat_type"
    t.index ["meeting_session_id", "category_type_id"], name: "meeting_category_type"
    t.index ["meeting_session_id", "event_order"], name: "meeting_order"
    t.index ["meeting_session_id", "event_type_id"], name: "meeting_event_type"
    t.index ["meeting_session_id", "gender_type_id"], name: "meeting_gender_type"
    t.index ["time_standard_id"], name: "idx_di_meeting_programs_time_standard"
    t.index ["user_id"], name: "idx_di_meeting_programs_user"
  end

  create_table "data_import_meeting_relay_results", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.integer "rank", default: 0
    t.boolean "is_play_off", default: false
    t.boolean "is_out_of_race", default: false
    t.boolean "is_disqualified", default: false
    t.decimal "standard_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_points", precision: 10, scale: 2, default: "0.0"
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundreds", limit: 2, default: 0
    t.integer "data_import_team_id"
    t.integer "team_id"
    t.integer "user_id"
    t.integer "data_import_meeting_program_id"
    t.integer "meeting_program_id"
    t.integer "disqualification_code_type_id"
    t.string "relay_header", limit: 60, default: ""
    t.decimal "reaction_time", precision: 5, scale: 2, default: "0.0"
    t.integer "entry_minutes", limit: 3
    t.integer "entry_seconds", limit: 2
    t.integer "entry_hundreds", limit: 2
    t.integer "team_affiliation_id"
    t.integer "entry_time_type_id"
    t.index ["data_import_meeting_program_id"], name: "idx_di_mrr_di_meeting_program"
    t.index ["data_import_session_id"], name: "idx_di_mrr_di_session"
    t.index ["data_import_team_id"], name: "idx_di_mrr_di_team"
    t.index ["disqualification_code_type_id"], name: "idx_di_mrr_disqualification_code_type"
    t.index ["entry_time_type_id"], name: "idx_di_mrr_entry_time_type"
    t.index ["meeting_program_id"], name: "idx_di_mrr_meeting_program"
    t.index ["team_affiliation_id"], name: "idx_di_mrr_team_affiliation"
    t.index ["team_id"], name: "idx_di_mrr_team"
    t.index ["user_id"], name: "idx_di_mrr_user"
  end

  create_table "data_import_meeting_relay_swimmers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "data_import_session_id"
    t.integer "conflicting_id", limit: 3, default: 0
    t.string "import_text", null: false
    t.decimal "reaction_time", precision: 5, scale: 2
    t.integer "minutes", limit: 3
    t.integer "seconds", limit: 2
    t.integer "hundreds", limit: 2
    t.integer "relay_order", limit: 3, default: 0
    t.integer "data_import_swimmer_id"
    t.integer "data_import_team_id"
    t.integer "data_import_badge_id"
    t.integer "swimmer_id"
    t.integer "badge_id"
    t.integer "stroke_type_id"
    t.integer "meeting_relay_result_id"
    t.integer "user_id"
    t.integer "data_import_meeting_relay_result_id"
    t.integer "team_id"
    t.index ["badge_id"], name: "idx_di_meeting_relay_swimmers_badge"
    t.index ["data_import_badge_id"], name: "idx_di_meeting_relay_swimmers_di_badge"
    t.index ["data_import_meeting_relay_result_id"], name: "idx_di_meeting_relay_swimmers_di_meeting_relay_result"
    t.index ["data_import_session_id"], name: "idx_di_meeting_relay_swimmers_di_session"
    t.index ["data_import_swimmer_id"], name: "idx_di_meeting_relay_swimmers_di_swimmer"
    t.index ["data_import_team_id"], name: "idx_di_meeting_relay_swimmers_di_team"
    t.index ["meeting_relay_result_id"], name: "idx_di_meeting_relay_swimmers_meeting_relay_result"
    t.index ["stroke_type_id"], name: "idx_di_meeting_relay_swimmers_stroke_type"
    t.index ["swimmer_id"], name: "idx_di_meeting_relay_swimmers_swimmer"
    t.index ["team_id"], name: "idx_di_meeting_relay_swimmers_team"
    t.index ["user_id"], name: "idx_di_meeting_relay_swimmers_user"
  end

  create_table "data_import_meeting_sessions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.integer "session_order", limit: 2, default: 0
    t.date "scheduled_date"
    t.time "warm_up_time"
    t.time "begin_time"
    t.text "notes"
    t.integer "data_import_meeting_id"
    t.integer "meeting_id"
    t.integer "swimming_pool_id"
    t.integer "user_id"
    t.string "description", limit: 100
    t.integer "day_part_type_id"
    t.index ["data_import_meeting_id"], name: "idx_di_meeting_sessions_di_meeting"
    t.index ["data_import_session_id"], name: "idx_di_meeting_sessions_di_session"
    t.index ["day_part_type_id"], name: "idx_di_meeting_sessions_day_part_type"
    t.index ["meeting_id"], name: "idx_di_meeting_sessions_meeting"
    t.index ["scheduled_date"], name: "index_data_import_meeting_sessions_on_scheduled_date"
    t.index ["swimming_pool_id"], name: "idx_di_meeting_sessions_swimming_pool"
    t.index ["user_id"], name: "idx_di_meeting_sessions_user"
  end

  create_table "data_import_meeting_team_scores", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.decimal "sum_individual_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "sum_relay_points", precision: 10, scale: 2, default: "0.0"
    t.integer "data_import_team_id"
    t.integer "data_import_meeting_id"
    t.integer "team_id"
    t.integer "meeting_id"
    t.integer "rank", default: 0
    t.integer "user_id"
    t.decimal "sum_team_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_individual_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_relay_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_team_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "season_individual_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "season_relay_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "season_team_points", precision: 10, scale: 2, default: "0.0"
    t.integer "season_id"
    t.integer "team_affiliation_id"
    t.index ["data_import_meeting_id"], name: "idx_di_meeting_team_scores_di_meeting"
    t.index ["data_import_session_id"], name: "idx_di_meeting_team_scores_di_session"
    t.index ["data_import_team_id"], name: "idx_di_meeting_team_scores_di_team"
    t.index ["meeting_id"], name: "idx_di_meeting_team_scores_meeting"
    t.index ["season_id"], name: "idx_di_meeting_team_scores_season"
    t.index ["team_affiliation_id"], name: "idx_di_meeting_team_scores_team_affiliation"
    t.index ["team_id"], name: "idx_di_meeting_team_scores_team"
    t.index ["user_id"], name: "idx_di_meeting_team_scores_user"
  end

  create_table "data_import_meetings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.string "description", limit: 100
    t.date "entry_deadline"
    t.boolean "has_warm_up_pool", default: false
    t.boolean "is_under_25_admitted", default: false
    t.string "reference_phone", limit: 40
    t.string "reference_e_mail", limit: 50
    t.string "reference_name", limit: 50
    t.text "notes"
    t.string "tag", limit: 20
    t.boolean "has_invitation", default: false
    t.boolean "has_start_list", default: false
    t.boolean "are_results_acquired", default: false
    t.integer "max_individual_events", limit: 1, default: 2
    t.string "configuration_file", limit: 50
    t.integer "edition", limit: 3, default: 0
    t.integer "data_import_season_id"
    t.integer "season_id"
    t.integer "user_id"
    t.date "header_date"
    t.string "code", limit: 50
    t.string "header_year", limit: 9
    t.integer "max_individual_events_per_session", limit: 2, default: 2
    t.boolean "is_out_of_season", default: false
    t.integer "edition_type_id"
    t.integer "timing_type_id"
    t.integer "individual_score_computation_type_id"
    t.integer "relay_score_computation_type_id"
    t.integer "team_score_computation_type_id"
    t.integer "meeting_score_computation_type_id"
    t.index ["code", "edition"], name: "idx_di_meetings_code"
    t.index ["data_import_season_id"], name: "idx_di_meetings_di_season"
    t.index ["data_import_session_id"], name: "idx_di_meetings_di_session"
    t.index ["edition_type_id"], name: "idx_di_meetings_edition_type"
    t.index ["entry_deadline"], name: "index_data_import_meetings_on_entry_deadline"
    t.index ["header_date"], name: "idx_di_meetings_header_date"
    t.index ["season_id"], name: "idx_di_meetings_season"
    t.index ["timing_type_id"], name: "idx_di_meetings_timing_type"
    t.index ["user_id"], name: "idx_di_meetings_user"
  end

  create_table "data_import_passages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "data_import_session_id"
    t.integer "conflicting_id", limit: 3, default: 0
    t.string "import_text", null: false
    t.decimal "reaction_time", precision: 5, scale: 2
    t.integer "minutes", limit: 3
    t.integer "seconds", limit: 2
    t.integer "hundreds", limit: 2
    t.integer "stroke_cycles", limit: 3
    t.integer "not_swam_part_seconds", limit: 2
    t.integer "not_swam_part_hundreds", limit: 2
    t.integer "not_swam_kick_number", limit: 2
    t.integer "breath_number", limit: 3
    t.integer "position", limit: 3
    t.integer "minutes_from_start", limit: 3
    t.integer "seconds_from_start", limit: 2
    t.integer "hundreds_from_start", limit: 2
    t.boolean "is_native_from_start", default: false
    t.integer "passage_type_id"
    t.integer "data_import_meeting_program_id"
    t.integer "data_import_meeting_individual_result_id"
    t.integer "data_import_meeting_entry_id"
    t.integer "data_import_swimmer_id"
    t.integer "data_import_team_id"
    t.integer "meeting_program_id"
    t.integer "meeting_individual_result_id"
    t.integer "meeting_entry_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "user_id"
    t.index ["data_import_meeting_entry_id"], name: "idx_di_passages_di_meeting_entry"
    t.index ["data_import_meeting_individual_result_id"], name: "idx_di_passages_di_meeting_individual_result"
    t.index ["data_import_meeting_program_id"], name: "idx_di_passages_di_meeting_program"
    t.index ["data_import_session_id"], name: "idx_di_passages_di_session"
    t.index ["data_import_swimmer_id"], name: "idx_di_passages_di_swimmer"
    t.index ["data_import_team_id"], name: "idx_di_passages_di_team"
    t.index ["meeting_entry_id"], name: "idx_di_passages_meeting_entry"
    t.index ["meeting_individual_result_id"], name: "idx_di_passages_meeting_individual_result"
    t.index ["meeting_program_id"], name: "idx_di_passages_meeting_program"
    t.index ["passage_type_id"], name: "idx_di_passages_passage_type"
    t.index ["swimmer_id"], name: "idx_di_passages_swimmer"
    t.index ["team_id"], name: "idx_di_passages_team"
    t.index ["user_id"], name: "idx_di_passages_user"
  end

  create_table "data_import_seasons", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.string "description", limit: 100
    t.date "begin_date"
    t.date "end_date"
    t.integer "season_type_id"
    t.string "header_year", limit: 9
    t.integer "edition", limit: 3, default: 0
    t.integer "edition_type_id"
    t.integer "timing_type_id"
    t.index ["begin_date"], name: "index_data_import_seasons_on_begin_date"
    t.index ["data_import_session_id"], name: "idx_di_seasons_di_session"
    t.index ["edition_type_id"], name: "idx_di_seasons_edition_type"
    t.index ["season_type_id"], name: "idx_di_seasons_season_type"
    t.index ["timing_type_id"], name: "idx_di_seasons_timing_type"
  end

  create_table "data_import_sessions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "file_name"
    t.text "source_data", limit: 16777215
    t.integer "phase"
    t.integer "total_data_rows"
    t.string "file_format"
    t.text "phase_1_log", limit: 16777215
    t.text "phase_2_log"
    t.text "phase_3_log", limit: 16777215
    t.integer "data_import_season_id"
    t.integer "season_id"
    t.integer "user_id"
    t.text "sql_diff"
    t.integer "log_verbosity", default: 0
    t.index ["data_import_season_id"], name: "idx_di_sessions_di_season"
    t.index ["season_id"], name: "idx_di_sessions_season"
    t.index ["user_id"], name: "user_id"
  end

  create_table "data_import_swimmer_aliases", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "complete_name", limit: 100
    t.integer "swimmer_id"
    t.index ["swimmer_id", "complete_name"], name: "idx_swimmer_id_complete_name", unique: true
  end

  create_table "data_import_swimmer_analysis_results", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.text "analysis_log_text", limit: 16777215
    t.text "sql_text", limit: 16777215
    t.string "searched_swimmer_name", limit: 100
    t.integer "chosen_swimmer_id"
    t.string "match_name", limit: 60
    t.decimal "match_score", precision: 10, scale: 4, default: "0.0"
    t.string "best_match_name", limit: 60
    t.decimal "best_match_score", precision: 10, scale: 4, default: "0.0"
    t.integer "desired_year_of_birth", default: 1900
    t.bigint "desired_gender_type_id"
    t.integer "max_year_of_birth"
    t.integer "category_type_id"
    t.index ["category_type_id"], name: "idx_di_swimmer_analysis_results_category_type"
    t.index ["data_import_session_id", "searched_swimmer_name", "desired_year_of_birth", "desired_gender_type_id"], name: "idx_di_session_swimmer_name", unique: true
    t.index ["desired_gender_type_id"], name: "idx_di_swimmer_gender_type"
  end

  create_table "data_import_swimmers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.string "last_name"
    t.string "first_name"
    t.integer "year_of_birth", default: 1900
    t.integer "gender_type_id"
    t.integer "user_id"
    t.string "complete_name", limit: 100
    t.index ["complete_name"], name: "index_data_import_swimmers_on_complete_name"
    t.index ["data_import_session_id"], name: "idx_di_swimmers_di_session"
    t.index ["gender_type_id"], name: "idx_di_swimmers_gender_type"
    t.index ["last_name", "first_name"], name: "full_name"
    t.index ["user_id"], name: "idx_di_swimmers_user"
  end

  create_table "data_import_team_aliases", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "name", limit: 60
    t.integer "team_id"
    t.index ["team_id", "name"], name: "idx_team_id_name", unique: true
  end

  create_table "data_import_team_analysis_results", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.text "analysis_log_text", limit: 16777215
    t.text "sql_text"
    t.string "searched_team_name", limit: 60
    t.integer "desired_season_id"
    t.integer "chosen_team_id"
    t.string "team_match_name", limit: 60
    t.decimal "team_match_score", precision: 10, scale: 4, default: "0.0"
    t.string "best_match_name", limit: 60
    t.decimal "best_match_score", precision: 10, scale: 4, default: "0.0"
    t.index ["data_import_session_id", "searched_team_name", "desired_season_id"], name: "idx_di_session_name_and_season", unique: true
  end

  create_table "data_import_teams", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "data_import_session_id"
    t.bigint "conflicting_id", default: 0
    t.string "import_text"
    t.string "name", limit: 60
    t.string "badge_number", limit: 40
    t.integer "data_import_city_id"
    t.integer "city_id"
    t.integer "user_id"
    t.index ["city_id"], name: "city_id"
    t.index ["data_import_city_id"], name: "data_import_city_id"
    t.index ["data_import_session_id"], name: "idx_di_teams_di_session"
    t.index ["name"], name: "index_data_import_teams_on_name"
    t.index ["user_id"], name: "idx_di_teams_user"
  end

  create_table "day_part_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 1
    t.index ["code"], name: "index_day_part_types_on_code", unique: true
  end

  create_table "day_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 6
    t.integer "week_order", limit: 3, default: 0
    t.index ["code"], name: "index_day_types_on_code", unique: true
  end

  create_table "delayed_jobs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "disqualification_code_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 4
    t.boolean "is_a_relay", default: false
    t.integer "stroke_type_id"
    t.index ["is_a_relay", "code"], name: "code", unique: true
    t.index ["is_a_relay"], name: "index_disqualification_code_types_on_is_a_relay"
    t.index ["stroke_type_id"], name: "idx_disqualification_code_types_stroke_type"
  end

  create_table "edition_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 1
    t.index ["code"], name: "index_edition_types_on_code", unique: true
  end

  create_table "entry_time_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "idx_entry_time_types_code", unique: true
  end

  create_table "event_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 10
    t.bigint "length_in_meters"
    t.boolean "is_a_relay", default: false
    t.integer "stroke_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "style_order", limit: 2, default: 0
    t.boolean "is_mixed_gender", default: false
    t.integer "partecipants", limit: 2, default: 4
    t.integer "phases", limit: 2, default: 4
    t.integer "phase_length_in_meters", limit: 3, default: 50
    t.index ["is_a_relay", "code"], name: "code", unique: true
    t.index ["is_a_relay"], name: "index_event_types_on_is_a_relay"
    t.index ["stroke_type_id"], name: "fk_event_types_stroke_types"
    t.index ["style_order"], name: "index_event_types_on_style_order"
  end

  create_table "events_by_pool_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.integer "pool_type_id"
    t.integer "event_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_type_id"], name: "fk_events_by_pool_types_event_types"
    t.index ["pool_type_id"], name: "fk_events_by_pool_types_pool_types"
  end

  create_table "execution_note_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 3
    t.index ["code"], name: "index_execution_note_types_on_code", unique: true
  end

  create_table "exercise_rows", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "part_order", limit: 3, default: 0
    t.integer "percentage", limit: 3, default: 0
    t.integer "start_and_rest", default: 0
    t.integer "pause", default: 0
    t.integer "exercise_id"
    t.integer "base_movement_id"
    t.integer "training_mode_type_id"
    t.integer "execution_note_type_id"
    t.integer "distance", default: 0
    t.index ["base_movement_id"], name: "fk_exercise_rows_base_movements"
    t.index ["execution_note_type_id"], name: "fk_exercise_rows_execution_note_types"
    t.index ["exercise_id", "part_order"], name: "idx_exercise_rows_part_order"
    t.index ["training_mode_type_id"], name: "fk_exercise_rows_training_mode_types"
  end

  create_table "exercises", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 6
    t.integer "user_id"
    t.string "training_step_type_codes", limit: 50
    t.index ["code"], name: "index_exercises_on_code", unique: true
    t.index ["user_id"], name: "idx_exercises_user"
  end

  create_table "federation_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 4
    t.string "description", limit: 100
    t.string "short_name", limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_federation_types_on_code", unique: true
  end

  create_table "fin_calendars", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "calendar_date"
    t.string "calendar_name"
    t.string "calendar_place"
    t.string "fin_manifest_code"
    t.string "fin_startlist_code"
    t.string "fin_results_code"
    t.string "goggles_meeting_code"
    t.integer "season_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "calendar_year", limit: 4
    t.string "calendar_month", limit: 20
    t.string "results_link"
    t.string "startlist_link"
    t.string "manifest_link"
    t.text "manifest"
    t.text "name_import_text"
    t.text "organization_import_text"
    t.text "place_import_text"
    t.text "dates_import_text"
    t.text "program_import_text"
    t.integer "meeting_id"
    t.boolean "do_not_update", default: false, null: false
    t.index ["goggles_meeting_code"], name: "index_fin_calendars_on_goggles_meeting_code"
    t.index ["meeting_id"], name: "index_fin_calendars_on_meeting_id"
    t.index ["season_id"], name: "index_fin_calendars_on_season_id"
    t.index ["user_id"], name: "index_fin_calendars_on_user_id"
  end

  create_table "friendships", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "friendable_id"
    t.integer "friend_id"
    t.integer "blocker_id"
    t.boolean "pending", default: true
    t.boolean "shares_passages", default: false
    t.boolean "shares_trainings", default: false
    t.boolean "shares_calendars", default: false
    t.index ["friendable_id", "friend_id"], name: "index_friendships_on_friendable_id_and_friend_id", unique: true
  end

  create_table "gender_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_gender_types_on_code", unique: true
  end

  create_table "goggle_cup_definitions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.integer "goggle_cup_id"
    t.integer "season_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["goggle_cup_id"], name: "fk_goggle_cup_definitions_goggle_cups"
    t.index ["season_id"], name: "fk_goggle_cup_definitions_seasons"
  end

  create_table "goggle_cup_standards", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundreds", limit: 2, default: 0
    t.integer "event_type_id"
    t.integer "pool_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "reaction_time", precision: 5, scale: 2, default: "0.0"
    t.integer "goggle_cup_id"
    t.integer "swimmer_id"
    t.index ["event_type_id"], name: "fk_goggle_cup_standards_event_types"
    t.index ["goggle_cup_id", "swimmer_id", "pool_type_id", "event_type_id"], name: "idx_goggle_cup_standards_goggle_cup_swimmer_pool_event", unique: true
    t.index ["goggle_cup_id"], name: "fk_goggle_cup_standards_goggle_cups"
    t.index ["pool_type_id"], name: "fk_goggle_cup_standards_pool_types"
    t.index ["swimmer_id"], name: "fk_goggle_cup_standards_swimmers"
  end

  create_table "goggle_cups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "description", limit: 60
    t.integer "season_year", default: 2010
    t.integer "max_points", default: 1000
    t.integer "team_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "max_performance", limit: 2, default: 5
    t.boolean "is_limited_to_season_types_defined", default: false, null: false
    t.date "end_date"
    t.integer "age_for_negative_modifier", default: 20
    t.decimal "negative_modifier", precision: 10, scale: 2, default: "-10.0"
    t.integer "age_for_positive_modifier", default: 60
    t.decimal "positive_modifier", precision: 10, scale: 2, default: "5.0"
    t.boolean "has_to_create_standards", default: true
    t.boolean "has_to_update_standards", default: false
    t.text "pre_calculation_sql"
    t.text "post_calculation_sql"
    t.boolean "is_team_limited", default: true
    t.integer "career_step", default: 100
    t.decimal "career_bonus", precision: 10, scale: 2, default: "0.0"
    t.index ["season_year"], name: "idx_season_year"
    t.index ["team_id"], name: "fk_goggle_cups_teams"
    t.index ["user_id"], name: "idx_goggle_cups_user"
  end

  create_table "hair_dryer_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_hair_dryer_types_on_code", unique: true
  end

  create_table "heat_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_default_value", default: false
    t.index ["code"], name: "idx_heat_types_code", unique: true
  end

  create_table "individual_records", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "pool_type_id"
    t.integer "event_type_id"
    t.integer "category_type_id"
    t.integer "gender_type_id"
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundreds", limit: 2, default: 0
    t.boolean "is_team_record", default: false
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "season_id"
    t.integer "federation_type_id"
    t.integer "meeting_individual_result_id"
    t.integer "record_type_id"
    t.index ["category_type_id"], name: "idx_individual_records_category_type"
    t.index ["event_type_id"], name: "idx_individual_records_event_type"
    t.index ["federation_type_id"], name: "idx_individual_records_federation_type"
    t.index ["gender_type_id"], name: "idx_individual_records_gender_type"
    t.index ["meeting_individual_result_id"], name: "idx_individual_records_meeting_individual_result"
    t.index ["pool_type_id"], name: "idx_individual_records_pool_type"
    t.index ["record_type_id"], name: "fk_individual_records_record_types"
    t.index ["season_id"], name: "idx_individual_records_season"
    t.index ["swimmer_id"], name: "idx_individual_records_swimmer"
    t.index ["team_id"], name: "idx_individual_records_team"
  end

  create_table "kick_aux_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_kick_aux_types_on_code", unique: true
  end

  create_table "locker_cabinet_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_locker_cabinet_types_on_code", unique: true
  end

  create_table "medal_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rank", default: 0
    t.integer "weigth", default: 0
    t.string "image_uri", limit: 50
    t.index ["code"], name: "index_medal_types_on_code", unique: true
  end

  create_table "meeting_entries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "start_list_number"
    t.integer "lane_number", limit: 2
    t.integer "heat_number"
    t.integer "heat_arrival_order", limit: 2
    t.integer "meeting_program_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "team_affiliation_id"
    t.integer "badge_id"
    t.integer "entry_time_type_id"
    t.integer "user_id"
    t.integer "minutes", limit: 3
    t.integer "seconds", limit: 2
    t.integer "hundreds", limit: 2
    t.boolean "is_no_time", default: false
    t.index ["badge_id"], name: "idx_meeting_entries_badge"
    t.index ["entry_time_type_id"], name: "idx_meeting_entries_entry_time_type"
    t.index ["meeting_program_id"], name: "idx_meeting_entries_meeting_program"
    t.index ["swimmer_id"], name: "idx_meeting_entries_swimmer"
    t.index ["team_affiliation_id"], name: "idx_meeting_entries_team_affiliation"
    t.index ["team_id"], name: "idx_meeting_entries_team"
    t.index ["user_id"], name: "idx_meeting_entries_user"
  end

  create_table "meeting_event_reservations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "meeting_id"
    t.integer "team_id"
    t.integer "swimmer_id"
    t.integer "badge_id"
    t.integer "meeting_event_id"
    t.integer "user_id"
    t.integer "suggested_minutes", limit: 3
    t.integer "suggested_seconds", limit: 2
    t.integer "suggested_hundreds", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_doing_this", default: false, null: false
    t.index ["badge_id"], name: "index_meeting_event_reservations_on_badge_id"
    t.index ["meeting_event_id"], name: "index_meeting_event_reservations_on_meeting_event_id"
    t.index ["meeting_id"], name: "index_meeting_event_reservations_on_meeting_id"
    t.index ["swimmer_id"], name: "index_meeting_event_reservations_on_swimmer_id"
    t.index ["team_id"], name: "index_meeting_event_reservations_on_team_id"
    t.index ["user_id"], name: "index_meeting_event_reservations_on_user_id"
  end

  create_table "meeting_events", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "event_order", limit: 3, default: 0
    t.time "begin_time"
    t.boolean "is_out_of_race", default: false
    t.boolean "is_autofilled", default: false
    t.text "notes"
    t.integer "meeting_session_id"
    t.integer "event_type_id"
    t.integer "heat_type_id"
    t.integer "user_id"
    t.boolean "has_separate_gender_start_list", default: true
    t.boolean "has_separate_category_start_list", default: false
    t.index ["event_type_id"], name: "fk_meeting_events_event_types"
    t.index ["heat_type_id"], name: "fk_meeting_events_heat_types"
    t.index ["meeting_session_id"], name: "fk_meeting_events_meeting_sessions"
    t.index ["user_id"], name: "idx_meeting_events_user"
  end

  create_table "meeting_individual_results", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.integer "rank", default: 0
    t.boolean "is_play_off", default: false
    t.boolean "is_out_of_race", default: false
    t.boolean "is_disqualified", default: false
    t.decimal "standard_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_individual_points", precision: 10, scale: 2, default: "0.0"
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundreds", limit: 2, default: 0
    t.integer "meeting_program_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.integer "badge_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "disqualification_code_type_id"
    t.decimal "goggle_cup_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "reaction_time", precision: 5, scale: 2, default: "0.0"
    t.decimal "team_points", precision: 10, scale: 2, default: "0.0"
    t.integer "team_affiliation_id"
    t.boolean "is_personal_best", default: false, null: false
    t.boolean "is_season_type_best", default: false, null: false
    t.index ["badge_id"], name: "fk_meeting_individual_results_badges"
    t.index ["disqualification_code_type_id"], name: "idx_mir_disqualification_code_type"
    t.index ["meeting_program_id"], name: "fk_meeting_individual_results_meeting_programs"
    t.index ["swimmer_id"], name: "fk_meeting_individual_results_swimmers"
    t.index ["team_affiliation_id"], name: "fk_meeting_individual_results_team_affiliations"
    t.index ["team_id"], name: "fk_meeting_individual_results_teams"
    t.index ["updated_at"], name: "idx_meeting_individual_results_updated_at"
    t.index ["user_id"], name: "idx_mir_user"
  end

  create_table "meeting_programs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.integer "event_order", limit: 3, default: 0
    t.integer "category_type_id"
    t.integer "gender_type_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_autofilled", default: false
    t.boolean "is_out_of_race", default: false
    t.time "begin_time"
    t.integer "meeting_event_id"
    t.integer "pool_type_id"
    t.integer "time_standard_id"
    t.index ["category_type_id"], name: "meeting_category_type"
    t.index ["event_order"], name: "meeting_order"
    t.index ["gender_type_id"], name: "meeting_gender_type"
    t.index ["meeting_event_id"], name: "fk_meeting_programs_meeting_events"
    t.index ["pool_type_id"], name: "fk_meeting_programs_pool_types"
    t.index ["time_standard_id"], name: "fk_meeting_programs_time_standards"
    t.index ["user_id"], name: "idx_meeting_programs_user"
  end

  create_table "meeting_relay_reservations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "meeting_id"
    t.integer "user_id"
    t.integer "team_id"
    t.integer "swimmer_id"
    t.integer "badge_id"
    t.integer "meeting_event_id"
    t.string "notes", limit: 50
    t.boolean "is_doing_this"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_meeting_relay_reservations_on_badge_id"
    t.index ["meeting_event_id"], name: "index_meeting_relay_reservations_on_meeting_event_id"
    t.index ["meeting_id"], name: "index_meeting_relay_reservations_on_meeting_id"
    t.index ["swimmer_id"], name: "index_meeting_relay_reservations_on_swimmer_id"
    t.index ["team_id"], name: "index_meeting_relay_reservations_on_team_id"
    t.index ["user_id"], name: "index_meeting_relay_reservations_on_user_id"
  end

  create_table "meeting_relay_results", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rank", default: 0
    t.boolean "is_play_off", default: false
    t.boolean "is_out_of_race", default: false
    t.boolean "is_disqualified", default: false
    t.decimal "standard_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_points", precision: 10, scale: 2, default: "0.0"
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundreds", limit: 2, default: 0
    t.integer "team_id"
    t.integer "user_id"
    t.integer "meeting_program_id"
    t.integer "disqualification_code_type_id"
    t.string "relay_header", limit: 60, default: ""
    t.decimal "reaction_time", precision: 5, scale: 2, default: "0.0"
    t.integer "entry_minutes", limit: 3
    t.integer "entry_seconds", limit: 2
    t.integer "entry_hundreds", limit: 2
    t.integer "team_affiliation_id"
    t.integer "entry_time_type_id"
    t.index ["disqualification_code_type_id"], name: "idx_mrr_disqualification_code_type"
    t.index ["entry_time_type_id"], name: "fk_meeting_relay_results_entry_time_types"
    t.index ["meeting_program_id", "rank"], name: "results_x_relay"
    t.index ["team_affiliation_id"], name: "fk_meeting_relay_results_team_affiliations"
    t.index ["team_id"], name: "fk_meeting_relay_results_teams"
    t.index ["user_id"], name: "idx_mrr_user"
  end

  create_table "meeting_relay_swimmers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "relay_order", limit: 3, default: 0
    t.integer "swimmer_id"
    t.integer "badge_id"
    t.integer "stroke_type_id"
    t.integer "user_id"
    t.decimal "reaction_time", precision: 5, scale: 2, default: "0.0"
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundreds", limit: 2, default: 0
    t.integer "meeting_relay_result_id"
    t.index ["badge_id"], name: "fk_meeting_relay_swimmers_badges"
    t.index ["meeting_relay_result_id"], name: "fk_meeting_relay_swimmers_meeting_relay_results"
    t.index ["relay_order"], name: "relay_order"
    t.index ["stroke_type_id"], name: "fk_meeting_relay_swimmers_stroke_types"
    t.index ["swimmer_id"], name: "fk_meeting_relay_swimmers_swimmers"
    t.index ["user_id"], name: "idx_meeting_relay_swimmers_user"
  end

  create_table "meeting_reservations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "meeting_id"
    t.integer "user_id"
    t.integer "team_id"
    t.integer "swimmer_id"
    t.integer "badge_id"
    t.text "notes"
    t.boolean "is_not_coming"
    t.boolean "has_confirmed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id"], name: "index_meeting_reservations_on_badge_id"
    t.index ["meeting_id"], name: "index_meeting_reservations_on_meeting_id"
    t.index ["swimmer_id"], name: "index_meeting_reservations_on_swimmer_id"
    t.index ["team_id"], name: "index_meeting_reservations_on_team_id"
    t.index ["user_id"], name: "index_meeting_reservations_on_user_id"
  end

  create_table "meeting_sessions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.integer "session_order", limit: 2, default: 0
    t.date "scheduled_date"
    t.time "warm_up_time"
    t.time "begin_time"
    t.text "notes"
    t.integer "meeting_id"
    t.integer "swimming_pool_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "description", limit: 100
    t.boolean "is_autofilled", default: false
    t.integer "day_part_type_id"
    t.index ["day_part_type_id"], name: "fk_meeting_sessions_day_part_types"
    t.index ["meeting_id"], name: "fk_meeting_sessions_meetings"
    t.index ["scheduled_date"], name: "index_meeting_sessions_on_scheduled_date"
    t.index ["swimming_pool_id"], name: "fk_meeting_sessions_swimming_pools"
    t.index ["user_id"], name: "idx_meeting_sessions_user"
  end

  create_table "meeting_team_scores", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.decimal "sum_individual_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "sum_relay_points", precision: 10, scale: 2, default: "0.0"
    t.integer "team_id"
    t.integer "meeting_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "rank", default: 0
    t.integer "user_id"
    t.decimal "sum_team_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_individual_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_relay_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_team_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "season_individual_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "season_relay_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "season_team_points", precision: 10, scale: 2, default: "0.0"
    t.integer "season_id"
    t.integer "team_affiliation_id"
    t.index ["meeting_id", "team_id"], name: "teams_x_meeting"
    t.index ["season_id"], name: "fk_meeting_team_scores_seasons"
    t.index ["team_affiliation_id"], name: "fk_meeting_team_scores_team_affiliations"
    t.index ["team_id"], name: "fk_meeting_team_scores_teams"
    t.index ["user_id"], name: "idx_meeting_team_scores_user"
  end

  create_table "meetings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "description", limit: 100
    t.date "entry_deadline"
    t.boolean "has_warm_up_pool", default: false
    t.boolean "is_under_25_admitted", default: false
    t.string "reference_phone", limit: 40
    t.string "reference_e_mail", limit: 50
    t.string "reference_name", limit: 50
    t.text "notes"
    t.boolean "has_invitation", default: false
    t.boolean "has_start_list", default: false
    t.boolean "are_results_acquired", default: false
    t.integer "max_individual_events", limit: 1, default: 2
    t.string "configuration_file"
    t.integer "edition", limit: 3, default: 0
    t.integer "season_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_autofilled", default: false
    t.date "header_date"
    t.string "code", limit: 50
    t.string "header_year", limit: 9
    t.integer "max_individual_events_per_session", limit: 2, default: 2
    t.boolean "is_out_of_season", default: false
    t.integer "edition_type_id"
    t.integer "timing_type_id"
    t.integer "individual_score_computation_type_id"
    t.integer "relay_score_computation_type_id"
    t.integer "team_score_computation_type_id"
    t.integer "meeting_score_computation_type_id"
    t.text "invitation", limit: 16777215
    t.boolean "is_confirmed", default: false, null: false
    t.boolean "is_tweeted", default: false
    t.boolean "is_fb_posted", default: false
    t.boolean "is_cancelled", default: false
    t.boolean "is_pb_scanned", default: false
    t.bigint "organization_team_id"
    t.boolean "do_not_update", default: false, null: false
    t.decimal "meeting_fee", precision: 10, scale: 2
    t.decimal "event_fee", precision: 10, scale: 2
    t.decimal "relay_fee", precision: 10, scale: 2
    t.index ["code", "edition"], name: "idx_meetings_code"
    t.index ["edition_type_id"], name: "fk_meetings_edition_types"
    t.index ["entry_deadline"], name: "index_meetings_on_entry_deadline"
    t.index ["header_date"], name: "idx_meetings_header_date"
    t.index ["individual_score_computation_type_id"], name: "fk_meetings_score_individual_score_computation_types"
    t.index ["meeting_score_computation_type_id"], name: "fk_meetings_score_meeting_score_computation_types"
    t.index ["organization_team_id"], name: "index_meetings_on_organization_team_id"
    t.index ["relay_score_computation_type_id"], name: "fk_meetings_score_relay_score_computation_types"
    t.index ["season_id"], name: "fk_meetings_seasons"
    t.index ["team_score_computation_type_id"], name: "fk_meetings_score_team_score_computation_types"
    t.index ["timing_type_id"], name: "fk_meetings_timing_types"
    t.index ["user_id"], name: "idx_meetings_user"
  end

  create_table "movement_scope_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 1
    t.index ["code"], name: "index_movement_scope_types_on_code", unique: true
  end

  create_table "movement_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 1
    t.index ["code"], name: "index_movement_types_on_code", unique: true
  end

  create_table "nation_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.string "numeric_code", limit: 3
    t.string "alpha2_code", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_nation_types_on_code", unique: true
  end

  create_table "news_feeds", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title", limit: 150
    t.text "body"
    t.boolean "is_read", default: false
    t.boolean "is_friend_activity", default: false
    t.boolean "is_achievement", default: false
    t.integer "user_id"
    t.integer "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "idx_news_feeds_user"
  end

  create_table "passage_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 6
    t.integer "length_in_meters", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_passage_types_on_code", unique: true
  end

  create_table "passages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundreds", limit: 2, default: 0
    t.integer "meeting_program_id"
    t.integer "passage_type_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "reaction_time", precision: 5, scale: 2
    t.integer "stroke_cycles", limit: 3
    t.integer "not_swam_part_seconds", limit: 2
    t.integer "not_swam_part_hundreds", limit: 2
    t.integer "not_swam_kick_number", limit: 2
    t.integer "breath_number", limit: 3
    t.integer "position", limit: 3
    t.integer "minutes_from_start", limit: 3
    t.integer "seconds_from_start", limit: 2
    t.integer "hundreds_from_start", limit: 2
    t.boolean "is_native_from_start", default: false
    t.integer "meeting_individual_result_id"
    t.integer "meeting_entry_id"
    t.integer "swimmer_id"
    t.integer "team_id"
    t.index ["meeting_entry_id"], name: "idx_passages_meeting_entry"
    t.index ["meeting_individual_result_id"], name: "idx_passages_meeting_individual_result"
    t.index ["meeting_program_id"], name: "passages_x_badges"
    t.index ["passage_type_id"], name: "fk_passages_passage_types"
    t.index ["swimmer_id"], name: "idx_passages_swimmer"
    t.index ["team_id"], name: "idx_passages_team"
    t.index ["user_id"], name: "idx_passages_user"
  end

  create_table "pool_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.integer "length_in_meters", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_suitable_for_meetings", default: true
    t.index ["code"], name: "index_pool_types_on_code", unique: true
  end

  create_table "presence_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 1
    t.integer "value", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_presence_types_on_code", unique: true
  end

  create_table "rails_admin_histories", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text "message"
    t.string "username"
    t.integer "item"
    t.string "table"
    t.integer "month", limit: 2
    t.bigint "year"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["item", "table", "month", "year"], name: "index_rails_admin_histories"
  end

  create_table "record_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_for_swimmers", default: false
    t.boolean "is_for_teams", default: false
    t.boolean "is_for_seasons", default: false
    t.index ["code"], name: "index_record_types_on_code", unique: true
  end

  create_table "region_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.integer "nation_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["code"], name: "index_region_types_on_code"
    t.index ["nation_type_id", "code"], name: "index_region_types_nation_code"
    t.index ["nation_type_id"], name: "index_region_types_on_nation_type_id"
  end

  create_table "score_computation_type_rows", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "class_name", limit: 100
    t.string "method_name", limit: 100
    t.decimal "default_score", precision: 10, scale: 2, default: "0.0"
    t.integer "score_computation_type_id"
    t.integer "score_mapping_type_id"
    t.bigint "computation_order", default: 0
    t.integer "position_limit", default: 0
    t.index ["computation_order"], name: "idx_score_computation_type_rows_computation_order"
    t.index ["score_computation_type_id"], name: "fk_score_computation_type_rows_score_computation_types"
    t.index ["score_mapping_type_id"], name: "idx_score_computation_type_rows_score_mapping_type"
  end

  create_table "score_computation_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 6
    t.index ["code"], name: "index_score_computation_types_on_code", unique: true
  end

  create_table "score_mapping_type_rows", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.bigint "position", default: 0
    t.decimal "score", precision: 10, scale: 2, default: "0.0"
    t.integer "score_mapping_type_id"
    t.index ["score_mapping_type_id"], name: "idx_score_mapping_type_rows_score_mapping_type"
  end

  create_table "score_mapping_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 6
    t.index ["code"], name: "index_score_mapping_types_on_code", unique: true
  end

  create_table "season_personal_standards", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.integer "minutes", limit: 3, default: 0, null: false
    t.integer "seconds", limit: 2, default: 0, null: false
    t.integer "hundreds", limit: 2, default: 0, null: false
    t.integer "season_id"
    t.integer "swimmer_id"
    t.integer "event_type_id"
    t.integer "pool_type_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["season_id", "swimmer_id", "pool_type_id", "event_type_id"], name: "idx_season_personal_standards_season_swimmer_event_pool", unique: true
    t.index ["season_id"], name: "idx_season_personal_standards_season_id"
    t.index ["swimmer_id"], name: "idx_season_personal_standards_swimmer_id"
  end

  create_table "season_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 10
    t.string "description", limit: 100
    t.string "short_name", limit: 40
    t.integer "federation_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_season_types_on_code", unique: true
    t.index ["federation_type_id"], name: "fk_season_types_federation_types"
  end

  create_table "seasons", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "description", limit: 100
    t.date "begin_date"
    t.date "end_date"
    t.integer "season_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "header_year", limit: 9
    t.integer "edition", limit: 3, default: 0
    t.integer "edition_type_id"
    t.integer "timing_type_id"
    t.text "rules", limit: 16777215
    t.boolean "has_individual_rank", default: true
    t.decimal "badge_fee", precision: 10, scale: 2
    t.index ["begin_date"], name: "index_seasons_on_begin_date"
    t.index ["edition_type_id"], name: "fk_seasons_edition_types"
    t.index ["season_type_id"], name: "fk_seasons_season_types"
    t.index ["timing_type_id"], name: "fk_seasons_timing_types"
  end

  create_table "sessions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "session_id"
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "shower_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_shower_types_on_code", unique: true
  end

  create_table "stroke_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_eventable", default: false
    t.index ["code"], name: "index_stroke_types_on_code", unique: true
    t.index ["is_eventable"], name: "idx_is_eventable"
  end

  create_table "swimmer_level_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.integer "level", limit: 3, default: 0
    t.integer "achievement_id"
    t.index ["achievement_id"], name: "idx_swimmer_level_types_achievement"
    t.index ["code"], name: "index_swimmer_level_types_on_code", unique: true
  end

  create_table "swimmer_season_scores", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.decimal "score", precision: 10, scale: 2
    t.integer "badge_id"
    t.integer "meeting_individual_result_id"
    t.integer "event_type_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["badge_id", "event_type_id"], name: "swimmer_season_scores_badge_event"
    t.index ["badge_id", "score"], name: "swimmer_season_scores_badge_score"
    t.index ["badge_id"], name: "index_swimmer_season_scores_on_badge_id"
    t.index ["event_type_id"], name: "index_swimmer_season_scores_on_event_type_id"
    t.index ["meeting_individual_result_id"], name: "index_swimmer_season_scores_on_meeting_individual_result_id"
    t.index ["user_id"], name: "index_swimmer_season_scores_on_user_id"
  end

  create_table "swimmers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "last_name", limit: 50
    t.string "first_name", limit: 50
    t.integer "year_of_birth", default: 1900
    t.string "phone_mobile", limit: 40
    t.string "phone_number", limit: 40
    t.string "e_mail", limit: 100
    t.string "nickname", limit: 25, default: ""
    t.bigint "associated_user_id"
    t.integer "gender_type_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "complete_name", limit: 100
    t.boolean "is_year_guessed", default: false
    t.index ["associated_user_id"], name: "index_swimmers_on_associated_user_id"
    t.index ["complete_name", "year_of_birth"], name: "name_and_year", unique: true
    t.index ["complete_name"], name: "index_swimmers_on_complete_name"
    t.index ["gender_type_id"], name: "fk_swimmers_gender_types"
    t.index ["last_name", "first_name"], name: "full_name"
    t.index ["nickname"], name: "index_swimmers_on_nickname"
    t.index ["user_id"], name: "idx_swimmers_user"
  end

  create_table "swimming_pool_reviews", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "title", limit: 100
    t.text "entry_text"
    t.integer "user_id"
    t.integer "swimming_pool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["swimming_pool_id"], name: "fk_swimming_pool_reviews_swimming_pools"
    t.index ["title"], name: "index_swimming_pool_reviews_on_title"
    t.index ["user_id"], name: "idx_swimming_pool_reviews_user"
  end

  create_table "swimming_pools", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "name", limit: 100
    t.string "address", limit: 100
    t.string "zip", limit: 6
    t.string "nick_name", limit: 50
    t.string "phone_number", limit: 40
    t.string "fax_number", limit: 40
    t.string "e_mail", limit: 100
    t.string "contact_name", limit: 100
    t.string "maps_uri"
    t.integer "lanes_number", limit: 2, default: 8
    t.boolean "has_multiple_pools", default: false
    t.boolean "has_open_area", default: false
    t.boolean "has_bar", default: false
    t.boolean "has_restaurant_service", default: false
    t.boolean "has_gym_area", default: false
    t.boolean "has_children_area", default: false
    t.text "notes"
    t.integer "city_id"
    t.integer "pool_type_id"
    t.integer "shower_type_id"
    t.integer "hair_dryer_type_id"
    t.integer "locker_cabinet_type_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "do_not_update", default: false, null: false
    t.index ["city_id"], name: "fk_swimming_pools_cities"
    t.index ["hair_dryer_type_id"], name: "fk_swimming_pools_hair_dryer_types"
    t.index ["locker_cabinet_type_id"], name: "fk_swimming_pools_locker_cabinet_types"
    t.index ["name"], name: "index_swimming_pools_on_name"
    t.index ["nick_name"], name: "index_swimming_pools_on_nick_name", unique: true
    t.index ["pool_type_id"], name: "fk_swimming_pools_pool_types"
    t.index ["shower_type_id"], name: "fk_swimming_pools_shower_types"
    t.index ["user_id"], name: "idx_swimming_pools_user"
  end

  create_table "taggings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", collation: "utf8_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "team_affiliations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "number", limit: 20
    t.string "name", limit: 100
    t.boolean "must_calculate_goggle_cup", default: false
    t.integer "team_id"
    t.integer "season_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_autofilled", default: false
    t.index ["name"], name: "index_team_affiliations_on_name"
    t.index ["number"], name: "index_team_affiliations_on_number"
    t.index ["season_id", "team_id"], name: "uk_team_affiliations_seasons_teams", unique: true
    t.index ["team_id"], name: "fk_team_affiliations_teams"
    t.index ["user_id"], name: "idx_team_affiliations_user"
  end

  create_table "team_managers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "team_affiliation_id"
    t.integer "user_id"
    t.index ["team_affiliation_id", "user_id"], name: "team_manager_with_affiliation", unique: true
    t.index ["team_affiliation_id"], name: "index_team_managers_on_team_affiliation_id"
    t.index ["user_id"], name: "index_team_managers_on_user_id"
  end

  create_table "team_passage_templates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.integer "part_order", limit: 3, default: 0
    t.boolean "has_subtotal", default: false
    t.boolean "has_cycle_count", default: false
    t.boolean "has_breath_count", default: false
    t.boolean "has_non_swam_part", default: false
    t.boolean "has_non_swam_kick_count", default: false
    t.boolean "has_passage_position", default: false
    t.integer "team_id"
    t.integer "event_type_id"
    t.integer "pool_type_id"
    t.integer "passage_type_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["event_type_id"], name: "idx_team_passage_templates_event_type"
    t.index ["passage_type_id"], name: "idx_team_passage_templates_passage_type"
    t.index ["pool_type_id"], name: "idx_team_passage_templates_pool_type"
    t.index ["team_id"], name: "idx_team_passage_templates_team"
    t.index ["user_id"], name: "idx_team_passage_templates_user"
  end

  create_table "teams", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "name", limit: 60
    t.string "editable_name", limit: 60
    t.string "address", limit: 100
    t.string "zip", limit: 6
    t.string "phone_mobile", limit: 40
    t.string "phone_number", limit: 40
    t.string "fax_number", limit: 40
    t.string "e_mail", limit: 100
    t.string "contact_name", limit: 100
    t.text "notes"
    t.text "name_variations"
    t.integer "city_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "home_page_url", limit: 150
    t.index ["city_id"], name: "fk_teams_cities"
    t.index ["editable_name"], name: "index_teams_on_editable_name"
    t.index ["name"], name: "index_teams_on_name"
    t.index ["user_id"], name: "idx_teams_user"
  end

  create_table "time_standards", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundreds", limit: 2, default: 0
    t.integer "season_id"
    t.integer "gender_type_id"
    t.integer "pool_type_id"
    t.integer "event_type_id"
    t.integer "category_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["category_type_id"], name: "fk_time_standards_category_types"
    t.index ["event_type_id"], name: "fk_time_standards_event_types"
    t.index ["gender_type_id"], name: "fk_time_standards_gender_types"
    t.index ["pool_type_id"], name: "fk_time_standards_pool_types"
    t.index ["season_id"], name: "fk_time_standards_seasons"
  end

  create_table "timing_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "code", limit: 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_timing_types_on_code", unique: true
  end

  create_table "training_mode_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 5
    t.index ["code"], name: "index_training_mode_types_on_code", unique: true
  end

  create_table "training_rows", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "part_order", limit: 3, default: 0
    t.integer "times", limit: 3, default: 0
    t.integer "distance", default: 0
    t.integer "start_and_rest", default: 0
    t.integer "pause", default: 0
    t.integer "training_id"
    t.integer "exercise_id"
    t.integer "training_step_type_id"
    t.integer "group_id", limit: 3, default: 0
    t.integer "group_times", limit: 3, default: 0
    t.integer "group_start_and_rest", default: 0
    t.integer "group_pause", default: 0
    t.integer "arm_aux_type_id"
    t.integer "kick_aux_type_id"
    t.integer "body_aux_type_id"
    t.integer "breath_aux_type_id"
    t.index ["arm_aux_type_id"], name: "fk_training_rows_arm_aux_types"
    t.index ["body_aux_type_id"], name: "fk_training_rows_body_aux_types"
    t.index ["breath_aux_type_id"], name: "fk_training_rows_breath_aux_types"
    t.index ["exercise_id"], name: "fk_training_exercises"
    t.index ["group_id", "part_order"], name: "index_training_rows_on_group_id_and_part_order"
    t.index ["kick_aux_type_id"], name: "fk_training_rows_kick_aux_types"
    t.index ["training_id", "part_order"], name: "idx_training_rows_part_order"
    t.index ["training_step_type_id"], name: "fk_training_rows_training_step_types"
  end

  create_table "training_step_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "code", limit: 1
    t.integer "step_order", limit: 3, default: 0
    t.index ["code"], name: "index_training_step_types_on_code", unique: true
    t.index ["step_order"], name: "index_training_step_types_on_step_order"
  end

  create_table "trainings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "title", limit: 100, default: ""
    t.text "description"
    t.integer "user_id"
    t.integer "min_swimmer_level", limit: 3, default: 0
    t.integer "max_swimmer_level", limit: 3, default: 0
    t.index ["title"], name: "index_trainings_on_title", unique: true
    t.index ["user_id"], name: "idx_trainings_user"
  end

  create_table "user_achievements", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "achievement_id"
    t.index ["user_id", "achievement_id"], name: "index_user_achievements_on_user_id_and_achievement_id", unique: true
  end

  create_table "user_results", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.decimal "standard_points", precision: 10, scale: 2, default: "0.0"
    t.decimal "meeting_points", precision: 10, scale: 2, default: "0.0"
    t.bigint "rank", default: 0
    t.boolean "is_disqualified", default: false
    t.integer "minutes", limit: 3, default: 0
    t.integer "seconds", limit: 2, default: 0
    t.integer "hundreds", limit: 2, default: 0
    t.integer "swimmer_id"
    t.integer "category_type_id"
    t.integer "pool_type_id"
    t.integer "meeting_individual_result_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "disqualification_code_type_id"
    t.string "description", limit: 60, default: ""
    t.date "event_date"
    t.decimal "reaction_time", precision: 10, scale: 2, default: "0.0"
    t.integer "event_type_id"
    t.index ["category_type_id"], name: "fk_user_results_category_types"
    t.index ["disqualification_code_type_id"], name: "idx_user_results_disqualification_code_type"
    t.index ["event_type_id"], name: "fk_user_results_event_types"
    t.index ["meeting_individual_result_id", "rank"], name: "meeting_id_rank"
    t.index ["pool_type_id"], name: "fk_user_results_pool_types"
    t.index ["swimmer_id"], name: "fk_user_results_swimmers"
    t.index ["user_id"], name: "idx_user_results_user"
  end

  create_table "user_swimmer_confirmations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "swimmer_id"
    t.integer "user_id"
    t.integer "confirmator_id"
    t.index ["confirmator_id"], name: "index_user_swimmer_confirmations_on_confirmator_id"
    t.index ["user_id", "swimmer_id", "confirmator_id"], name: "user_swimmer_confirmator", unique: true
  end

  create_table "user_training_rows", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "part_order", limit: 3, default: 0
    t.integer "times", limit: 3, default: 0
    t.integer "distance", default: 0
    t.integer "start_and_rest", default: 0
    t.integer "pause", default: 0
    t.integer "group_id", limit: 3, default: 0
    t.integer "group_times", limit: 3, default: 0
    t.integer "group_start_and_rest", default: 0
    t.integer "group_pause", default: 0
    t.integer "user_training_id"
    t.integer "exercise_id"
    t.integer "training_step_type_id"
    t.integer "arm_aux_type_id"
    t.integer "kick_aux_type_id"
    t.integer "body_aux_type_id"
    t.integer "breath_aux_type_id"
    t.index ["arm_aux_type_id"], name: "idx_user_training_rows_arm_aux_type"
    t.index ["body_aux_type_id"], name: "idx_user_training_rows_body_aux_type"
    t.index ["breath_aux_type_id"], name: "idx_user_training_rows_breath_aux_type"
    t.index ["exercise_id"], name: "idx_user_training_rows_exercise"
    t.index ["group_id", "part_order"], name: "index_user_training_rows_on_group_id_and_part_order"
    t.index ["kick_aux_type_id"], name: "idx_user_training_rows_kick_aux_type"
    t.index ["training_step_type_id"], name: "idx_user_training_rows_training_step_type"
    t.index ["user_training_id", "part_order"], name: "idx_user_training_rows_part_order"
  end

  create_table "user_training_stories", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "swam_date"
    t.integer "total_training_time", limit: 3, default: 0
    t.text "notes"
    t.integer "user_training_id"
    t.integer "swimming_pool_id"
    t.integer "swimmer_level_type_id"
    t.integer "user_id"
    t.index ["swimmer_level_type_id"], name: "idx_user_training_stories_swimmer_level_type"
    t.index ["swimming_pool_id"], name: "idx_user_training_stories_swimming_pool"
    t.index ["user_id"], name: "idx_user_training_stories_user"
    t.index ["user_training_id", "swam_date"], name: "index_user_training_stories_on_user_training_id_and_swam_date"
  end

  create_table "user_trainings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "description", limit: 250, default: ""
    t.integer "user_id"
    t.index ["user_id", "description"], name: "index_user_trainings_on_user_id_and_description"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "lock_version", default: 0
    t.string "name"
    t.string "description", limit: 100
    t.integer "swimmer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email", default: ""
    t.string "encrypted_password", default: ""
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    t.boolean "use_email_data_updates_notify", default: false
    t.boolean "use_email_achievements_notify", default: false
    t.boolean "use_email_newsletter_notify", default: false
    t.boolean "use_email_community_notify", default: false
    t.string "avatar_resource_filename", limit: 250
    t.integer "swimmer_level_type_id"
    t.integer "coach_level_type_id"
    t.string "authentication_token"
    t.integer "outstanding_goggle_score_bias", default: 800
    t.integer "outstanding_standard_score_bias", default: 800
    t.string "last_name", limit: 50
    t.string "first_name", limit: 50
    t.integer "year_of_birth", default: 1900
    t.bigint "facebook_uid"
    t.bigint "goggle_uid"
    t.bigint "twitter_uid"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["coach_level_type_id"], name: "idx_users_coach_level_type"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["last_name", "first_name", "year_of_birth"], name: "full_name"
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["swimmer_id"], name: "idx_users_swimmer"
    t.index ["swimmer_level_type_id"], name: "idx_users_swimmer_level_type"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "votes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "votable_id"
    t.string "votable_type"
    t.integer "voter_id"
    t.string "voter_type"
    t.boolean "vote_flag"
    t.string "vote_scope"
    t.integer "vote_weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["votable_id", "votable_type", "vote_scope"], name: "index_votes_on_votable_id_and_votable_type_and_vote_scope"
    t.index ["votable_id", "votable_type"], name: "index_votes_on_votable_id_and_votable_type"
    t.index ["voter_id", "voter_type", "vote_scope"], name: "index_votes_on_voter_id_and_voter_type_and_vote_scope"
    t.index ["voter_id", "voter_type"], name: "index_votes_on_voter_id_and_voter_type"
  end

  add_foreign_key "area_types", "region_types"
  add_foreign_key "cities", "area_types"
  add_foreign_key "meeting_event_reservations", "badges"
  add_foreign_key "meeting_event_reservations", "meeting_events"
  add_foreign_key "meeting_event_reservations", "meetings"
  add_foreign_key "meeting_event_reservations", "swimmers"
  add_foreign_key "meeting_event_reservations", "teams"
  add_foreign_key "meeting_event_reservations", "users"
  add_foreign_key "meeting_relay_reservations", "badges"
  add_foreign_key "meeting_relay_reservations", "meeting_events"
  add_foreign_key "meeting_relay_reservations", "meetings"
  add_foreign_key "meeting_relay_reservations", "swimmers"
  add_foreign_key "meeting_relay_reservations", "teams"
  add_foreign_key "meeting_relay_reservations", "users"
  add_foreign_key "meeting_reservations", "badges"
  add_foreign_key "meeting_reservations", "meetings"
  add_foreign_key "meeting_reservations", "swimmers"
  add_foreign_key "meeting_reservations", "teams"
  add_foreign_key "meeting_reservations", "users"
  add_foreign_key "region_types", "nation_types"
  add_foreign_key "swimmer_season_scores", "badges"
  add_foreign_key "swimmer_season_scores", "event_types"
  add_foreign_key "swimmer_season_scores", "meeting_individual_results"
  add_foreign_key "swimmer_season_scores", "users"
end
