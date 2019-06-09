# frozen_string_literal: true

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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(version: 20_160_205_143_425) do
  create_table 'achievement_rows', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'part_order',          limit: 3, default: 0
    t.string   'achievement_value',   limit: 10
    t.boolean  'is_bracket_open',                   default: false
    t.boolean  'is_or_operator',                    default: false
    t.boolean  'is_not_operator',                   default: false
    t.boolean  'is_bracket_closed',                 default: false
    t.integer  'achievement_id'
    t.integer  'achievement_type_id'
  end

  add_index 'achievement_rows', ['achievement_id'], name: 'idx_achievement_rows_achievement'
  add_index 'achievement_rows', ['achievement_type_id'], name: 'idx_achievement_rows_achievement_type'

  create_table 'achievement_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 5
  end

  add_index 'achievement_types', ['code'], name: 'index_achievement_types_on_code', unique: true

  create_table 'achievements', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 10
    t.integer  'user_id'
  end

  add_index 'achievements', ['code'], name: 'index_achievements_on_code', unique: true

  create_table 'admins', force: true do |t|
    t.string   'email',                            default: ''
    t.string   'encrypted_password',               default: ''
    t.integer  'sign_in_count',                    default: 0
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.string   'current_sign_in_ip'
    t.string   'last_sign_in_ip'
    t.integer  'failed_attempts', default: 0
    t.string   'unlock_token'
    t.datetime 'locked_at'
    t.integer  'lock_version', default: 0
    t.string   'name'
    t.string   'description', limit: 50
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'admins', ['email'], name: 'index_admins_on_email', unique: true
  add_index 'admins', ['name'], name: 'index_admins_on_name', unique: true
  add_index 'admins', ['unlock_token'], name: 'index_admins_on_unlock_token', unique: true

  create_table 'app_parameters', force: true do |t|
    t.integer  'lock_version', default: 0
    t.integer  'code'
    t.string   'controller_name'
    t.string   'action_name'
    t.boolean  'is_a_post', default: false
    t.string   'confirmation_text'
    t.string   'a_string'
    t.boolean  'a_bool'
    t.integer  'a_integer'
    t.datetime 'a_date'
    t.decimal  'a_decimal',                      precision: 10, scale: 2
    t.decimal  'a_decimal_2',                    precision: 10, scale: 2
    t.decimal  'a_decimal_3',                    precision: 10, scale: 2
    t.decimal  'a_decimal_4',                    precision: 10, scale: 2
    t.integer  'range_x',           limit: 8
    t.integer  'range_y',           limit: 8
    t.string   'a_name'
    t.string   'a_filename'
    t.string   'tooltip_text'
    t.integer  'view_height', default: 0
    t.integer  'code_type_1',       limit: 8
    t.integer  'code_type_2',       limit: 8
    t.integer  'code_type_3',       limit: 8
    t.integer  'code_type_4',       limit: 8
    t.text     'free_text_1'
    t.text     'free_text_2'
    t.text     'free_text_3'
    t.text     'free_text_4'
    t.boolean  'free_bool_1'
    t.boolean  'free_bool_2'
    t.boolean  'free_bool_3'
    t.boolean  'free_bool_4'
    t.text     'description'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'app_parameters', ['code'], name: 'index_app_parameters_on_code', unique: true

  create_table 'arm_aux_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 5
  end

  add_index 'arm_aux_types', ['code'], name: 'index_arm_aux_types_on_code', unique: true

  create_table 'articles', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'title', limit: 80
    t.text     'body'
    t.boolean  'is_sticky', default: false
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'articles', ['title'], name: 'index_articles_on_title'
  add_index 'articles', ['user_id'], name: 'idx_articles_user'

  create_table 'badges', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'number', limit: 40
    t.integer  'season_id'
    t.integer  'swimmer_id'
    t.integer  'team_id'
    t.integer  'category_type_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'entry_time_type_id'
    t.integer  'team_affiliation_id'
    t.integer  'final_rank'
  end

  add_index 'badges', ['category_type_id'], name: 'fk_badges_category_types'
  add_index 'badges', ['entry_time_type_id'], name: 'fk_badges_entry_time_types'
  add_index 'badges', ['number'], name: 'index_badges_on_number'
  add_index 'badges', ['season_id'], name: 'fk_badges_seasons'
  add_index 'badges', ['swimmer_id'], name: 'fk_badges_swimmers'
  add_index 'badges', ['team_affiliation_id'], name: 'fk_badges_team_affiliations'
  add_index 'badges', ['team_id'], name: 'fk_badges_teams'
  add_index 'badges', ['user_id'], name: 'idx_badges_user'

  create_table 'base_movements', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 6
    t.boolean  'is_arm_aux_allowed',                  default: false
    t.boolean  'is_kick_aux_allowed',                 default: false
    t.boolean  'is_body_aux_allowed',                 default: false
    t.boolean  'is_breath_aux_allowed',               default: false
    t.integer  'movement_type_id'
    t.integer  'stroke_type_id'
    t.integer  'movement_scope_type_id'
    t.integer  'user_id'
  end

  add_index 'base_movements', ['code'], name: 'index_base_movements_on_code', unique: true
  add_index 'base_movements', ['movement_scope_type_id'], name: 'fk_base_movements_movement_scope_types'
  add_index 'base_movements', ['movement_type_id'], name: 'fk_base_movements_movement_types'
  add_index 'base_movements', ['stroke_type_id'], name: 'fk_base_movements_stroke_types'
  add_index 'base_movements', ['user_id'], name: 'idx_base_movements_user'

  create_table 'body_aux_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 5
  end

  add_index 'body_aux_types', ['code'], name: 'index_body_aux_types_on_code', unique: true

  create_table 'breath_aux_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 5
  end

  add_index 'breath_aux_types', ['code'], name: 'index_breath_aux_types_on_code', unique: true

  create_table 'category_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code',            limit: 7
    t.string   'federation_code', limit: 2
    t.string   'description',     limit: 100
    t.string   'short_name',      limit: 50
    t.string   'group_name',      limit: 50
    t.integer  'age_begin',       limit: 3
    t.integer  'age_end',         limit: 3
    t.boolean  'is_a_relay', default: false
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'season_id'
    t.boolean  'is_out_of_race',                 default: false
    t.boolean  'is_undivided',                   default: false, null: false
  end

  add_index 'category_types', %w[federation_code is_a_relay], name: 'federation_code'
  add_index 'category_types', %w[season_id is_a_relay code], name: 'season_and_code', unique: true

  create_table 'cities', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'name',         limit: 50
    t.string   'zip',          limit: 6
    t.string   'area',         limit: 50
    t.string   'country',      limit: 50
    t.string   'country_code', limit: 10
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'user_id'
  end

  add_index 'cities', ['name'], name: 'index_cities_on_name'
  add_index 'cities', ['user_id'], name: 'idx_cities_user'
  add_index 'cities', ['zip'], name: 'index_cities_on_zip'

  create_table 'coach_level_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code',         limit: 5
    t.integer  'level',        limit: 3, default: 0
  end

  add_index 'coach_level_types', ['code'], name: 'index_coach_level_types_on_code', unique: true

  create_table 'comments', force: true do |t|
    t.integer  'lock_version',            default: 0
    t.string   'entry_text'
    t.integer  'user_id'
    t.integer  'swimming_pool_review_id'
    t.integer  'comment_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'comments', ['comment_id'], name: 'fk_comments_comments'
  add_index 'comments', ['swimming_pool_review_id'], name: 'fk_comments_swimming_pool_reviews'
  add_index 'comments', ['user_id'], name: 'idx_comments_user'

  create_table 'computed_season_rankings', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'rank', default: 0
    t.decimal  'total_points', precision: 10, scale: 2, default: 0.0
    t.integer  'team_id'
    t.integer  'season_id'
  end

  add_index 'computed_season_rankings', %w[season_id rank], name: 'rank_x_season'
  add_index 'computed_season_rankings', %w[season_id team_id], name: 'teams_x_season'
  add_index 'computed_season_rankings', ['team_id'], name: 'fk_computed_season_rankings_teams'

  create_table 'data_import_badges', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.string   'number', limit: 40
    t.integer  'data_import_swimmer_id'
    t.integer  'data_import_team_id'
    t.integer  'data_import_season_id'
    t.integer  'swimmer_id'
    t.integer  'team_id'
    t.integer  'season_id'
    t.integer  'category_type_id'
    t.integer  'user_id'
    t.integer  'entry_time_type_id'
    t.integer  'team_affiliation_id'
  end

  add_index 'data_import_badges', ['category_type_id'], name: 'idx_di_badges_category_type'
  add_index 'data_import_badges', ['data_import_season_id'], name: 'idx_di_badges_di_season'
  add_index 'data_import_badges', ['data_import_session_id'], name: 'idx_di_badges_di_session'
  add_index 'data_import_badges', ['data_import_swimmer_id'], name: 'idx_di_badges_di_swimmer'
  add_index 'data_import_badges', ['data_import_team_id'], name: 'idx_di_badges_di_team'
  add_index 'data_import_badges', ['entry_time_type_id'], name: 'idx_di_badges_entry_time_type'
  add_index 'data_import_badges', ['number'], name: 'index_data_import_badges_on_number'
  add_index 'data_import_badges', ['season_id'], name: 'idx_di_badges_season'
  add_index 'data_import_badges', ['swimmer_id'], name: 'idx_di_badges_swimmer'
  add_index 'data_import_badges', ['team_affiliation_id'], name: 'idx_di_badges_team_affiliation'
  add_index 'data_import_badges', ['team_id'], name: 'idx_di_badges_team'
  add_index 'data_import_badges', ['user_id'], name: 'idx_di_badges_user'

  create_table 'data_import_cities', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.string   'name',                   limit: 50
    t.string   'zip',                    limit: 6
    t.string   'area',                   limit: 50
    t.string   'country',                limit: 50
    t.string   'country_code',           limit: 10
    t.integer  'user_id'
  end

  add_index 'data_import_cities', ['data_import_session_id'], name: 'idx_di_cities_di_session'
  add_index 'data_import_cities', ['name'], name: 'index_data_import_cities_on_name'
  add_index 'data_import_cities', ['user_id'], name: 'idx_di_cities_user'
  add_index 'data_import_cities', ['zip'], name: 'index_data_import_cities_on_zip'

  create_table 'data_import_meeting_entries', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.string   'athlete_name',                   limit: 100
    t.string   'team_name',                      limit: 60
    t.string   'athlete_badge_number',           limit: 40
    t.string   'team_badge_number',              limit: 40
    t.integer  'year_of_birth', default: 1900
    t.integer  'minutes',                        limit: 3
    t.integer  'seconds',                        limit: 2
    t.integer  'hundreds',                       limit: 2
    t.boolean  'is_no_time', default: false
    t.integer  'start_list_number'
    t.integer  'lane_number', limit: 2
    t.integer  'heat_number'
    t.integer  'heat_arrival_order', limit: 2
    t.integer  'data_import_meeting_program_id'
    t.integer  'data_import_swimmer_id'
    t.integer  'data_import_team_id'
    t.integer  'data_import_badge_id'
    t.integer  'meeting_program_id'
    t.integer  'swimmer_id'
    t.integer  'team_id'
    t.integer  'team_affiliation_id'
    t.integer  'badge_id'
    t.integer  'entry_time_type_id'
    t.integer  'user_id'
  end

  add_index 'data_import_meeting_entries', ['badge_id'], name: 'idx_di_meeting_entries_badge'
  add_index 'data_import_meeting_entries', ['data_import_badge_id'], name: 'idx_di_meeting_entries_di_badge'
  add_index 'data_import_meeting_entries', ['data_import_meeting_program_id'], name: 'idx_di_meeting_entries_di_meeting_program'
  add_index 'data_import_meeting_entries', ['data_import_session_id'], name: 'idx_di_meeting_entries_di_session'
  add_index 'data_import_meeting_entries', ['data_import_swimmer_id'], name: 'idx_di_meeting_entries_di_swimmer'
  add_index 'data_import_meeting_entries', ['data_import_team_id'], name: 'idx_di_meeting_entries_di_team'
  add_index 'data_import_meeting_entries', ['entry_time_type_id'], name: 'idx_di_meeting_entries_entry_time_type'
  add_index 'data_import_meeting_entries', ['meeting_program_id'], name: 'idx_di_meeting_entries_meeting_program'
  add_index 'data_import_meeting_entries', ['swimmer_id'], name: 'idx_di_meeting_entries_swimmer'
  add_index 'data_import_meeting_entries', ['team_affiliation_id'], name: 'idx_di_meeting_entries_team_affiliation'
  add_index 'data_import_meeting_entries', ['team_id'], name: 'idx_di_meeting_entries_team'
  add_index 'data_import_meeting_entries', ['user_id'], name: 'idx_di_meeting_entries_user'

  create_table 'data_import_meeting_individual_results', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.string   'athlete_name',                   limit: 100
    t.string   'team_name',                      limit: 60
    t.string   'athlete_badge_number',           limit: 40
    t.string   'team_badge_number',              limit: 40
    t.integer  'year_of_birth',                                                                default: 1900
    t.integer  'rank',                                                                         default: 0
    t.boolean  'is_play_off',                                                                  default: false
    t.boolean  'is_out_of_race',                                                               default: false
    t.boolean  'is_disqualified',                                                              default: false
    t.decimal  'standard_points',                               precision: 10, scale: 2, default: 0.0
    t.decimal  'meeting_individual_points',                     precision: 10, scale: 2, default: 0.0
    t.integer  'minutes',                        limit: 3,                                  default: 0
    t.integer  'seconds',                        limit: 2,                                  default: 0
    t.integer  'hundreds',                       limit: 2,                                  default: 0
    t.integer  'data_import_meeting_program_id'
    t.integer  'meeting_program_id'
    t.integer  'data_import_swimmer_id'
    t.integer  'data_import_team_id'
    t.integer  'data_import_badge_id'
    t.integer  'swimmer_id'
    t.integer  'team_id'
    t.integer  'badge_id'
    t.integer  'user_id'
    t.integer  'disqualification_code_type_id'
    t.decimal  'goggle_cup_points',                             precision: 10, scale: 2, default: 0.0
    t.decimal  'reaction_time',                                 precision: 5,  scale: 2, default: 0.0
    t.decimal  'team_points',                                   precision: 10, scale: 2, default: 0.0
    t.integer  'team_affiliation_id'
  end

  add_index 'data_import_meeting_individual_results', ['badge_id'], name: 'idx_di_mir_badge'
  add_index 'data_import_meeting_individual_results', ['data_import_badge_id'], name: 'idx_di_mir_di_badge'
  add_index 'data_import_meeting_individual_results', ['data_import_meeting_program_id'], name: 'idx_di_mir_di_meeting_program'
  add_index 'data_import_meeting_individual_results', ['data_import_session_id'], name: 'idx_di_mir_di_session'
  add_index 'data_import_meeting_individual_results', ['data_import_swimmer_id'], name: 'idx_di_mir_di_swimmer'
  add_index 'data_import_meeting_individual_results', ['data_import_team_id'], name: 'idx_di_mir_di_team'
  add_index 'data_import_meeting_individual_results', ['disqualification_code_type_id'], name: 'idx_di_mir_disqualification_code_type'
  add_index 'data_import_meeting_individual_results', ['meeting_program_id'], name: 'idx_di_mir_meeting_program'
  add_index 'data_import_meeting_individual_results', ['swimmer_id'], name: 'idx_di_mir_swimmer'
  add_index 'data_import_meeting_individual_results', ['team_affiliation_id'], name: 'idx_di_mir_team_affiliation'
  add_index 'data_import_meeting_individual_results', ['team_id'], name: 'idx_di_mir_team'
  add_index 'data_import_meeting_individual_results', ['user_id'], name: 'idx_di_mir_user'

  create_table 'data_import_meeting_programs', force: true do |t|
    t.integer  'lock_version',                                default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.integer  'event_order', limit: 3, default: 0
    t.time     'begin_time'
    t.integer  'data_import_meeting_session_id'
    t.integer  'meeting_session_id'
    t.integer  'event_type_id'
    t.integer  'category_type_id'
    t.integer  'gender_type_id'
    t.integer  'user_id'
    t.integer  'minutes',                        limit: 3, default: 0
    t.integer  'seconds',                        limit: 2, default: 0
    t.integer  'hundreds',                       limit: 2, default: 0
    t.boolean  'is_out_of_race', default: false
    t.integer  'heat_type_id'
    t.integer  'time_standard_id'
  end

  add_index 'data_import_meeting_programs', ['data_import_meeting_session_id'], name: 'idx_di_meeting_programs_di_meeting_session'
  add_index 'data_import_meeting_programs', ['data_import_session_id'], name: 'idx_di_meeting_programs_di_session'
  add_index 'data_import_meeting_programs', ['heat_type_id'], name: 'idx_di_meeting_programs_heat_type'
  add_index 'data_import_meeting_programs', %w[meeting_session_id category_type_id], name: 'meeting_category_type'
  add_index 'data_import_meeting_programs', %w[meeting_session_id event_order], name: 'meeting_order'
  add_index 'data_import_meeting_programs', %w[meeting_session_id event_type_id], name: 'meeting_event_type'
  add_index 'data_import_meeting_programs', %w[meeting_session_id gender_type_id], name: 'meeting_gender_type'
  add_index 'data_import_meeting_programs', ['time_standard_id'], name: 'idx_di_meeting_programs_time_standard'
  add_index 'data_import_meeting_programs', ['user_id'], name: 'idx_di_meeting_programs_user'

  create_table 'data_import_meeting_relay_results', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.integer  'rank',                                                                        default: 0
    t.boolean  'is_play_off',                                                                 default: false
    t.boolean  'is_out_of_race',                                                              default: false
    t.boolean  'is_disqualified',                                                             default: false
    t.decimal  'standard_points',                              precision: 10, scale: 2, default: 0.0
    t.decimal  'meeting_points',                               precision: 10, scale: 2, default: 0.0
    t.integer  'minutes',                        limit: 3,                                 default: 0
    t.integer  'seconds',                        limit: 2,                                 default: 0
    t.integer  'hundreds',                       limit: 2,                                 default: 0
    t.integer  'data_import_team_id'
    t.integer  'team_id'
    t.integer  'user_id'
    t.integer  'data_import_meeting_program_id'
    t.integer  'meeting_program_id'
    t.integer  'disqualification_code_type_id'
    t.string   'relay_header', limit: 60, default: ''
    t.decimal  'reaction_time', precision: 5, scale: 2, default: 0.0
    t.integer  'entry_minutes',                  limit: 3
    t.integer  'entry_seconds',                  limit: 2
    t.integer  'entry_hundreds',                 limit: 2
    t.integer  'team_affiliation_id'
    t.integer  'entry_time_type_id'
  end

  add_index 'data_import_meeting_relay_results', ['data_import_meeting_program_id'], name: 'idx_di_mrr_di_meeting_program'
  add_index 'data_import_meeting_relay_results', ['data_import_session_id'], name: 'idx_di_mrr_di_session'
  add_index 'data_import_meeting_relay_results', ['data_import_team_id'], name: 'idx_di_mrr_di_team'
  add_index 'data_import_meeting_relay_results', ['disqualification_code_type_id'], name: 'idx_di_mrr_disqualification_code_type'
  add_index 'data_import_meeting_relay_results', ['entry_time_type_id'], name: 'idx_di_mrr_entry_time_type'
  add_index 'data_import_meeting_relay_results', ['meeting_program_id'], name: 'idx_di_mrr_meeting_program'
  add_index 'data_import_meeting_relay_results', ['team_affiliation_id'], name: 'idx_di_mrr_team_affiliation'
  add_index 'data_import_meeting_relay_results', ['team_id'], name: 'idx_di_mrr_team'
  add_index 'data_import_meeting_relay_results', ['user_id'], name: 'idx_di_mrr_user'

  create_table 'data_import_meeting_relay_swimmers', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at',                                                                                    null: false
    t.datetime 'updated_at',                                                                                    null: false
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 3, default: 0
    t.string   'import_text', null: false
    t.decimal  'reaction_time', precision: 5, scale: 2
    t.integer  'minutes',                             limit: 3
    t.integer  'seconds',                             limit: 2
    t.integer  'hundreds',                            limit: 2
    t.integer  'relay_order',                         limit: 3, default: 0
    t.integer  'data_import_swimmer_id'
    t.integer  'data_import_team_id'
    t.integer  'data_import_badge_id'
    t.integer  'swimmer_id'
    t.integer  'badge_id'
    t.integer  'stroke_type_id'
    t.integer  'meeting_relay_result_id'
    t.integer  'user_id'
    t.integer  'data_import_meeting_relay_result_id'
    t.integer  'team_id'
  end

  add_index 'data_import_meeting_relay_swimmers', ['badge_id'], name: 'idx_di_meeting_relay_swimmers_badge'
  add_index 'data_import_meeting_relay_swimmers', ['data_import_badge_id'], name: 'idx_di_meeting_relay_swimmers_di_badge'
  add_index 'data_import_meeting_relay_swimmers', ['data_import_meeting_relay_result_id'], name: 'idx_di_meeting_relay_swimmers_di_meeting_relay_result'
  add_index 'data_import_meeting_relay_swimmers', ['data_import_session_id'], name: 'idx_di_meeting_relay_swimmers_di_session'
  add_index 'data_import_meeting_relay_swimmers', ['data_import_swimmer_id'], name: 'idx_di_meeting_relay_swimmers_di_swimmer'
  add_index 'data_import_meeting_relay_swimmers', ['data_import_team_id'], name: 'idx_di_meeting_relay_swimmers_di_team'
  add_index 'data_import_meeting_relay_swimmers', ['meeting_relay_result_id'], name: 'idx_di_meeting_relay_swimmers_meeting_relay_result'
  add_index 'data_import_meeting_relay_swimmers', ['stroke_type_id'], name: 'idx_di_meeting_relay_swimmers_stroke_type'
  add_index 'data_import_meeting_relay_swimmers', ['swimmer_id'], name: 'idx_di_meeting_relay_swimmers_swimmer'
  add_index 'data_import_meeting_relay_swimmers', ['team_id'], name: 'idx_di_meeting_relay_swimmers_team'
  add_index 'data_import_meeting_relay_swimmers', ['user_id'], name: 'idx_di_meeting_relay_swimmers_user'

  create_table 'data_import_meeting_sessions', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.integer  'session_order', limit: 2, default: 0
    t.date     'scheduled_date'
    t.time     'warm_up_time'
    t.time     'begin_time'
    t.text     'notes'
    t.integer  'data_import_meeting_id'
    t.integer  'meeting_id'
    t.integer  'swimming_pool_id'
    t.integer  'user_id'
    t.string   'description', limit: 100
    t.integer  'day_part_type_id'
  end

  add_index 'data_import_meeting_sessions', ['data_import_meeting_id'], name: 'idx_di_meeting_sessions_di_meeting'
  add_index 'data_import_meeting_sessions', ['data_import_session_id'], name: 'idx_di_meeting_sessions_di_session'
  add_index 'data_import_meeting_sessions', ['day_part_type_id'], name: 'idx_di_meeting_sessions_day_part_type'
  add_index 'data_import_meeting_sessions', ['meeting_id'], name: 'idx_di_meeting_sessions_meeting'
  add_index 'data_import_meeting_sessions', ['scheduled_date'], name: 'index_data_import_meeting_sessions_on_scheduled_date'
  add_index 'data_import_meeting_sessions', ['swimming_pool_id'], name: 'idx_di_meeting_sessions_swimming_pool'
  add_index 'data_import_meeting_sessions', ['user_id'], name: 'idx_di_meeting_sessions_user'

  create_table 'data_import_meeting_team_scores', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.decimal  'sum_individual_points',                  precision: 10, scale: 2, default: 0.0
    t.decimal  'sum_relay_points',                       precision: 10, scale: 2, default: 0.0
    t.integer  'data_import_team_id'
    t.integer  'data_import_meeting_id'
    t.integer  'team_id'
    t.integer  'meeting_id'
    t.integer  'rank', default: 0
    t.integer  'user_id'
    t.decimal  'sum_team_points',                        precision: 10, scale: 2, default: 0.0
    t.decimal  'meeting_individual_points',              precision: 10, scale: 2, default: 0.0
    t.decimal  'meeting_relay_points',                   precision: 10, scale: 2, default: 0.0
    t.decimal  'meeting_team_points',                    precision: 10, scale: 2, default: 0.0
    t.decimal  'season_individual_points',               precision: 10, scale: 2, default: 0.0
    t.decimal  'season_relay_points',                    precision: 10, scale: 2, default: 0.0
    t.decimal  'season_team_points',                     precision: 10, scale: 2, default: 0.0
    t.integer  'season_id'
    t.integer  'team_affiliation_id'
  end

  add_index 'data_import_meeting_team_scores', ['data_import_meeting_id'], name: 'idx_di_meeting_team_scores_di_meeting'
  add_index 'data_import_meeting_team_scores', ['data_import_session_id'], name: 'idx_di_meeting_team_scores_di_session'
  add_index 'data_import_meeting_team_scores', ['data_import_team_id'], name: 'idx_di_meeting_team_scores_di_team'
  add_index 'data_import_meeting_team_scores', ['meeting_id'], name: 'idx_di_meeting_team_scores_meeting'
  add_index 'data_import_meeting_team_scores', ['season_id'], name: 'idx_di_meeting_team_scores_season'
  add_index 'data_import_meeting_team_scores', ['team_affiliation_id'], name: 'idx_di_meeting_team_scores_team_affiliation'
  add_index 'data_import_meeting_team_scores', ['team_id'], name: 'idx_di_meeting_team_scores_team'
  add_index 'data_import_meeting_team_scores', ['user_id'], name: 'idx_di_meeting_team_scores_user'

  create_table 'data_import_meetings', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.string   'description', limit: 100
    t.date     'entry_deadline'
    t.boolean  'has_warm_up_pool',                                    default: false
    t.boolean  'is_under_25_admitted',                                default: false
    t.string   'reference_phone',                      limit: 40
    t.string   'reference_e_mail',                     limit: 50
    t.string   'reference_name',                       limit: 50
    t.text     'notes'
    t.string   'tag', limit: 20
    t.boolean  'has_invitation',                                      default: false
    t.boolean  'has_start_list',                                      default: false
    t.boolean  'are_results_acquired',                                default: false
    t.integer  'max_individual_events',                limit: 1, default: 2
    t.string   'configuration_file',                   limit: 50
    t.integer  'edition',                              limit: 3, default: 0
    t.integer  'data_import_season_id'
    t.integer  'season_id'
    t.integer  'user_id'
    t.date     'header_date'
    t.string   'code',                                 limit: 50
    t.string   'header_year',                          limit: 9
    t.integer  'max_individual_events_per_session',    limit: 2, default: 2
    t.boolean  'is_out_of_season', default: false
    t.integer  'edition_type_id'
    t.integer  'timing_type_id'
    t.integer  'individual_score_computation_type_id'
    t.integer  'relay_score_computation_type_id'
    t.integer  'team_score_computation_type_id'
    t.integer  'meeting_score_computation_type_id'
  end

  add_index 'data_import_meetings', %w[code edition], name: 'idx_di_meetings_code'
  add_index 'data_import_meetings', ['data_import_season_id'], name: 'idx_di_meetings_di_season'
  add_index 'data_import_meetings', ['data_import_session_id'], name: 'idx_di_meetings_di_session'
  add_index 'data_import_meetings', ['edition_type_id'], name: 'idx_di_meetings_edition_type'
  add_index 'data_import_meetings', ['entry_deadline'], name: 'index_data_import_meetings_on_entry_deadline'
  add_index 'data_import_meetings', ['header_date'], name: 'idx_di_meetings_header_date'
  add_index 'data_import_meetings', ['season_id'], name: 'idx_di_meetings_season'
  add_index 'data_import_meetings', ['timing_type_id'], name: 'idx_di_meetings_timing_type'
  add_index 'data_import_meetings', ['user_id'], name: 'idx_di_meetings_user'

  create_table 'data_import_passages', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at',                                                                                             null: false
    t.datetime 'updated_at',                                                                                             null: false
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 3, default: 0
    t.string   'import_text', null: false
    t.decimal  'reaction_time', precision: 5, scale: 2
    t.integer  'minutes',                                  limit: 3
    t.integer  'seconds',                                  limit: 2
    t.integer  'hundreds',                                 limit: 2
    t.integer  'stroke_cycles',                            limit: 3
    t.integer  'not_swam_part_seconds',                    limit: 2
    t.integer  'not_swam_part_hundreds',                   limit: 2
    t.integer  'not_swam_kick_number',                     limit: 2
    t.integer  'breath_number',                            limit: 3
    t.integer  'position',                                 limit: 3
    t.integer  'minutes_from_start',                       limit: 3
    t.integer  'seconds_from_start',                       limit: 2
    t.integer  'hundreds_from_start',                      limit: 2
    t.boolean  'is_native_from_start', default: false
    t.integer  'passage_type_id'
    t.integer  'data_import_meeting_program_id'
    t.integer  'data_import_meeting_individual_result_id'
    t.integer  'data_import_meeting_entry_id'
    t.integer  'data_import_swimmer_id'
    t.integer  'data_import_team_id'
    t.integer  'meeting_program_id'
    t.integer  'meeting_individual_result_id'
    t.integer  'meeting_entry_id'
    t.integer  'swimmer_id'
    t.integer  'team_id'
    t.integer  'user_id'
  end

  add_index 'data_import_passages', ['data_import_meeting_entry_id'], name: 'idx_di_passages_di_meeting_entry'
  add_index 'data_import_passages', ['data_import_meeting_individual_result_id'], name: 'idx_di_passages_di_meeting_individual_result'
  add_index 'data_import_passages', ['data_import_meeting_program_id'], name: 'idx_di_passages_di_meeting_program'
  add_index 'data_import_passages', ['data_import_session_id'], name: 'idx_di_passages_di_session'
  add_index 'data_import_passages', ['data_import_swimmer_id'], name: 'idx_di_passages_di_swimmer'
  add_index 'data_import_passages', ['data_import_team_id'], name: 'idx_di_passages_di_team'
  add_index 'data_import_passages', ['meeting_entry_id'], name: 'idx_di_passages_meeting_entry'
  add_index 'data_import_passages', ['meeting_individual_result_id'], name: 'idx_di_passages_meeting_individual_result'
  add_index 'data_import_passages', ['meeting_program_id'], name: 'idx_di_passages_meeting_program'
  add_index 'data_import_passages', ['passage_type_id'], name: 'idx_di_passages_passage_type'
  add_index 'data_import_passages', ['swimmer_id'], name: 'idx_di_passages_swimmer'
  add_index 'data_import_passages', ['team_id'], name: 'idx_di_passages_team'
  add_index 'data_import_passages', ['user_id'], name: 'idx_di_passages_user'

  create_table 'data_import_seasons', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.string   'description', limit: 100
    t.date     'begin_date'
    t.date     'end_date'
    t.integer  'season_type_id'
    t.string   'header_year',            limit: 9
    t.integer  'edition',                limit: 3, default: 0
    t.integer  'edition_type_id'
    t.integer  'timing_type_id'
  end

  add_index 'data_import_seasons', ['begin_date'], name: 'index_data_import_seasons_on_begin_date'
  add_index 'data_import_seasons', ['data_import_session_id'], name: 'idx_di_seasons_di_session'
  add_index 'data_import_seasons', ['edition_type_id'], name: 'idx_di_seasons_edition_type'
  add_index 'data_import_seasons', ['season_type_id'], name: 'idx_di_seasons_season_type'
  add_index 'data_import_seasons', ['timing_type_id'], name: 'idx_di_seasons_timing_type'

  create_table 'data_import_sessions', force: true do |t|
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'file_name'
    t.text     'source_data', limit: 16_777_215
    t.integer  'phase'
    t.integer  'total_data_rows'
    t.string   'file_format'
    t.text     'phase_1_log', limit: 16_777_215
    t.text     'phase_2_log'
    t.text     'phase_3_log', limit: 16_777_215
    t.integer  'data_import_season_id'
    t.integer  'season_id'
    t.integer  'user_id'
    t.text     'sql_diff'
    t.integer  'log_verbosity', default: 0
  end

  add_index 'data_import_sessions', ['data_import_season_id'], name: 'idx_di_sessions_di_season'
  add_index 'data_import_sessions', ['season_id'], name: 'idx_di_sessions_season'
  add_index 'data_import_sessions', ['user_id'], name: 'user_id'

  create_table 'data_import_swimmer_aliases', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'complete_name', limit: 100
    t.integer  'swimmer_id'
  end

  add_index 'data_import_swimmer_aliases', %w[swimmer_id complete_name], name: 'idx_swimmer_id_complete_name', unique: true

  create_table 'data_import_swimmer_analysis_results', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.text     'analysis_log_text',      limit: 16_777_215
    t.text     'sql_text',               limit: 16_777_215
    t.string   'searched_swimmer_name',  limit: 100
    t.integer  'chosen_swimmer_id'
    t.string   'match_name', limit: 60
    t.decimal  'match_score', precision: 10, scale: 4, default: 0.0
    t.string   'best_match_name', limit: 60
    t.decimal  'best_match_score', precision: 10, scale: 4, default: 0.0
    t.integer  'desired_year_of_birth', default: 1900
    t.integer  'desired_gender_type_id', limit: 8
    t.integer  'max_year_of_birth'
    t.integer  'category_type_id'
  end

  add_index 'data_import_swimmer_analysis_results', ['category_type_id'], name: 'idx_di_swimmer_analysis_results_category_type'
  add_index 'data_import_swimmer_analysis_results', %w[data_import_session_id searched_swimmer_name desired_year_of_birth desired_gender_type_id], name: 'idx_di_session_swimmer_name', unique: true
  add_index 'data_import_swimmer_analysis_results', ['desired_gender_type_id'], name: 'idx_di_swimmer_gender_type'

  create_table 'data_import_swimmers', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.string   'last_name'
    t.string   'first_name'
    t.integer  'year_of_birth', default: 1900
    t.integer  'gender_type_id'
    t.integer  'user_id'
    t.string   'complete_name', limit: 100
  end

  add_index 'data_import_swimmers', ['complete_name'], name: 'index_data_import_swimmers_on_complete_name'
  add_index 'data_import_swimmers', ['data_import_session_id'], name: 'idx_di_swimmers_di_session'
  add_index 'data_import_swimmers', ['gender_type_id'], name: 'idx_di_swimmers_gender_type'
  add_index 'data_import_swimmers', %w[last_name first_name], name: 'full_name'
  add_index 'data_import_swimmers', ['user_id'], name: 'idx_di_swimmers_user'

  create_table 'data_import_team_aliases', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'name', limit: 60
    t.integer  'team_id'
  end

  add_index 'data_import_team_aliases', %w[team_id name], name: 'idx_team_id_name', unique: true

  create_table 'data_import_team_analysis_results', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.text     'analysis_log_text', limit: 16_777_215
    t.text     'sql_text'
    t.string   'searched_team_name', limit: 60
    t.integer  'desired_season_id'
    t.integer  'chosen_team_id'
    t.string   'team_match_name', limit: 60
    t.decimal  'team_match_score', precision: 10, scale: 4, default: 0.0
    t.string   'best_match_name', limit: 60
    t.decimal  'best_match_score', precision: 10, scale: 4, default: 0.0
  end

  add_index 'data_import_team_analysis_results', %w[data_import_session_id searched_team_name desired_season_id], name: 'idx_di_session_name_and_season', unique: true

  create_table 'data_import_teams', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'data_import_session_id'
    t.integer  'conflicting_id', limit: 8, default: 0
    t.string   'import_text'
    t.string   'name',                   limit: 60
    t.string   'badge_number',           limit: 40
    t.integer  'data_import_city_id'
    t.integer  'city_id'
    t.integer  'user_id'
  end

  add_index 'data_import_teams', ['city_id'], name: 'city_id'
  add_index 'data_import_teams', ['data_import_city_id'], name: 'data_import_city_id'
  add_index 'data_import_teams', ['data_import_session_id'], name: 'idx_di_teams_di_session'
  add_index 'data_import_teams', ['name'], name: 'index_data_import_teams_on_name'
  add_index 'data_import_teams', ['user_id'], name: 'idx_di_teams_user'

  create_table 'day_part_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 1
  end

  add_index 'day_part_types', ['code'], name: 'index_day_part_types_on_code', unique: true

  create_table 'day_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code',         limit: 6
    t.integer  'week_order',   limit: 3, default: 0
  end

  add_index 'day_types', ['code'], name: 'index_day_types_on_code', unique: true

  create_table 'delayed_jobs', force: true do |t|
    t.integer  'priority',   default: 0
    t.integer  'attempts',   default: 0
    t.text     'handler'
    t.text     'last_error'
    t.datetime 'run_at'
    t.datetime 'locked_at'
    t.datetime 'failed_at'
    t.string   'locked_by'
    t.string   'queue'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'delayed_jobs', %w[priority run_at], name: 'delayed_jobs_priority'

  create_table 'disqualification_code_types', force: true do |t|
    t.integer  'lock_version',                default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 4
    t.boolean  'is_a_relay', default: false
    t.integer  'stroke_type_id'
  end

  add_index 'disqualification_code_types', %w[is_a_relay code], name: 'code', unique: true
  add_index 'disqualification_code_types', ['is_a_relay'], name: 'index_disqualification_code_types_on_is_a_relay'
  add_index 'disqualification_code_types', ['stroke_type_id'], name: 'idx_disqualification_code_types_stroke_type'

  create_table 'edition_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 1
  end

  add_index 'edition_types', ['code'], name: 'index_edition_types_on_code', unique: true

  create_table 'entry_time_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code', limit: 1
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'entry_time_types', ['code'], name: 'idx_entry_time_types_code', unique: true

  create_table 'event_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code',                   limit: 10
    t.integer  'length_in_meters',       limit: 8
    t.boolean  'is_a_relay', default: false
    t.integer  'stroke_type_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'style_order', limit: 2, default: 0
    t.boolean  'is_mixed_gender', default: false
    t.integer  'partecipants',           limit: 2,  default: 4
    t.integer  'phases',                 limit: 2,  default: 4
    t.integer  'phase_length_in_meters', limit: 3,  default: 50
  end

  add_index 'event_types', %w[is_a_relay code], name: 'code', unique: true
  add_index 'event_types', ['is_a_relay'], name: 'index_event_types_on_is_a_relay'
  add_index 'event_types', ['stroke_type_id'], name: 'fk_event_types_stroke_types'
  add_index 'event_types', ['style_order'], name: 'index_event_types_on_style_order'

  create_table 'events_by_pool_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.integer  'pool_type_id'
    t.integer  'event_type_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'events_by_pool_types', ['event_type_id'], name: 'fk_events_by_pool_types_event_types'
  add_index 'events_by_pool_types', ['pool_type_id'], name: 'fk_events_by_pool_types_pool_types'

  create_table 'execution_note_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 3
  end

  add_index 'execution_note_types', ['code'], name: 'index_execution_note_types_on_code', unique: true

  create_table 'exercise_rows', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'part_order',             limit: 3, default: 0
    t.integer  'percentage',             limit: 3, default: 0
    t.integer  'start_and_rest',                      default: 0
    t.integer  'pause',                               default: 0
    t.integer  'exercise_id'
    t.integer  'base_movement_id'
    t.integer  'training_mode_type_id'
    t.integer  'execution_note_type_id'
    t.integer  'distance', default: 0
  end

  add_index 'exercise_rows', ['base_movement_id'], name: 'fk_exercise_rows_base_movements'
  add_index 'exercise_rows', ['execution_note_type_id'], name: 'fk_exercise_rows_execution_note_types'
  add_index 'exercise_rows', %w[exercise_id part_order], name: 'idx_exercise_rows_part_order'
  add_index 'exercise_rows', ['training_mode_type_id'], name: 'fk_exercise_rows_training_mode_types'

  create_table 'exercises', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 6
    t.integer  'user_id'
    t.string   'training_step_type_codes', limit: 50
  end

  add_index 'exercises', ['code'], name: 'index_exercises_on_code', unique: true
  add_index 'exercises', ['user_id'], name: 'idx_exercises_user'

  create_table 'federation_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code',         limit: 4
    t.string   'description',  limit: 100
    t.string   'short_name',   limit: 10
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'federation_types', ['code'], name: 'index_federation_types_on_code', unique: true

  create_table 'friendships', force: true do |t|
    t.integer 'friendable_id'
    t.integer 'friend_id'
    t.integer 'blocker_id'
    t.boolean 'pending',          default: true
    t.boolean 'shares_passages',  default: false
    t.boolean 'shares_trainings', default: false
    t.boolean 'shares_calendars', default: false
  end

  add_index 'friendships', %w[friendable_id friend_id], name: 'index_friendships_on_friendable_id_and_friend_id', unique: true

  create_table 'gender_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code', limit: 1
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'gender_types', ['code'], name: 'index_gender_types_on_code', unique: true

  create_table 'goggle_cup_definitions', force: true do |t|
    t.integer  'lock_version', default: 0
    t.integer  'goggle_cup_id'
    t.integer  'season_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'goggle_cup_definitions', ['goggle_cup_id'], name: 'fk_goggle_cup_definitions_goggle_cups'
  add_index 'goggle_cup_definitions', ['season_id'], name: 'fk_goggle_cup_definitions_seasons'

  create_table 'goggle_cup_standards', force: true do |t|
    t.integer  'lock_version', default: 0
    t.integer  'minutes',       limit: 3,                               default: 0
    t.integer  'seconds',       limit: 2,                               default: 0
    t.integer  'hundreds',      limit: 2,                               default: 0
    t.integer  'event_type_id'
    t.integer  'pool_type_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.decimal  'reaction_time', precision: 5, scale: 2, default: 0.0
    t.integer  'goggle_cup_id'
    t.integer  'swimmer_id'
  end

  add_index 'goggle_cup_standards', ['event_type_id'], name: 'fk_goggle_cup_standards_event_types'
  add_index 'goggle_cup_standards', ['goggle_cup_id'], name: 'fk_goggle_cup_standards_goggle_cups'
  add_index 'goggle_cup_standards', ['pool_type_id'], name: 'fk_goggle_cup_standards_pool_types'
  add_index 'goggle_cup_standards', ['swimmer_id'], name: 'fk_goggle_cup_standards_swimmers'

  create_table 'goggle_cups', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'description', limit: 60
    t.integer  'season_year',                                      default: 2010
    t.integer  'max_points',                                       default: 1000
    t.integer  'team_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'user_id'
    t.integer  'max_performance', limit: 2, default: 5
    t.boolean  'is_limited_to_season_types_defined', default: false, null: false
    t.date     'end_date'
  end

  add_index 'goggle_cups', ['season_year'], name: 'idx_season_year'
  add_index 'goggle_cups', ['team_id'], name: 'fk_goggle_cups_teams'
  add_index 'goggle_cups', ['user_id'], name: 'idx_goggle_cups_user'

  create_table 'hair_dryer_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code', limit: 3
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'hair_dryer_types', ['code'], name: 'index_hair_dryer_types_on_code', unique: true

  create_table 'heat_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code', limit: 10
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean  'is_default_value', default: false
  end

  add_index 'heat_types', ['code'], name: 'idx_heat_types_code', unique: true

  create_table 'individual_records', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'pool_type_id'
    t.integer  'event_type_id'
    t.integer  'category_type_id'
    t.integer  'gender_type_id'
    t.integer  'minutes',                      limit: 3, default: 0
    t.integer  'seconds',                      limit: 2, default: 0
    t.integer  'hundreds',                     limit: 2, default: 0
    t.boolean  'is_team_record', default: false
    t.integer  'swimmer_id'
    t.integer  'team_id'
    t.integer  'season_id'
    t.integer  'federation_type_id'
    t.integer  'meeting_individual_result_id'
    t.integer  'record_type_id'
  end

  add_index 'individual_records', ['category_type_id'], name: 'idx_individual_records_category_type'
  add_index 'individual_records', ['event_type_id'], name: 'idx_individual_records_event_type'
  add_index 'individual_records', ['federation_type_id'], name: 'idx_individual_records_federation_type'
  add_index 'individual_records', ['gender_type_id'], name: 'idx_individual_records_gender_type'
  add_index 'individual_records', ['meeting_individual_result_id'], name: 'idx_individual_records_meeting_individual_result'
  add_index 'individual_records', ['pool_type_id'], name: 'idx_individual_records_pool_type'
  add_index 'individual_records', ['record_type_id'], name: 'fk_individual_records_record_types'
  add_index 'individual_records', ['season_id'], name: 'idx_individual_records_season'
  add_index 'individual_records', ['swimmer_id'], name: 'idx_individual_records_swimmer'
  add_index 'individual_records', ['team_id'], name: 'idx_individual_records_team'

  create_table 'kick_aux_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 5
  end

  add_index 'kick_aux_types', ['code'], name: 'index_kick_aux_types_on_code', unique: true

  create_table 'locker_cabinet_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code', limit: 3
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'locker_cabinet_types', ['code'], name: 'index_locker_cabinet_types_on_code', unique: true

  create_table 'medal_types', force: true do |t|
    t.integer  'lock_version',               default: 0
    t.string   'code', limit: 1
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'rank',                       default: 0
    t.integer  'weigth',                     default: 0
    t.string   'image_uri', limit: 50
  end

  add_index 'medal_types', ['code'], name: 'index_medal_types_on_code', unique: true

  create_table 'meeting_entries', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'start_list_number'
    t.integer  'lane_number', limit: 2
    t.integer  'heat_number'
    t.integer  'heat_arrival_order', limit: 2
    t.integer  'meeting_program_id'
    t.integer  'swimmer_id'
    t.integer  'team_id'
    t.integer  'team_affiliation_id'
    t.integer  'badge_id'
    t.integer  'entry_time_type_id'
    t.integer  'user_id'
    t.integer  'minutes',             limit: 3
    t.integer  'seconds',             limit: 2
    t.integer  'hundreds',            limit: 2
    t.boolean  'is_no_time', default: false
  end

  add_index 'meeting_entries', ['badge_id'], name: 'idx_meeting_entries_badge'
  add_index 'meeting_entries', ['entry_time_type_id'], name: 'idx_meeting_entries_entry_time_type'
  add_index 'meeting_entries', ['meeting_program_id'], name: 'idx_meeting_entries_meeting_program'
  add_index 'meeting_entries', ['swimmer_id'], name: 'idx_meeting_entries_swimmer'
  add_index 'meeting_entries', ['team_affiliation_id'], name: 'idx_meeting_entries_team_affiliation'
  add_index 'meeting_entries', ['team_id'], name: 'idx_meeting_entries_team'
  add_index 'meeting_entries', ['user_id'], name: 'idx_meeting_entries_user'

  create_table 'meeting_events', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'event_order', limit: 3, default: 0
    t.time     'begin_time'
    t.boolean  'is_out_of_race',                                default: false
    t.boolean  'is_autofilled',                                 default: false
    t.text     'notes'
    t.integer  'meeting_session_id'
    t.integer  'event_type_id'
    t.integer  'heat_type_id'
    t.integer  'user_id'
    t.boolean  'has_separate_gender_start_list',                default: true
    t.boolean  'has_separate_category_start_list',              default: false
  end

  add_index 'meeting_events', ['event_type_id'], name: 'fk_meeting_events_event_types'
  add_index 'meeting_events', ['heat_type_id'], name: 'fk_meeting_events_heat_types'
  add_index 'meeting_events', ['meeting_session_id'], name: 'fk_meeting_events_meeting_sessions'
  add_index 'meeting_events', ['user_id'], name: 'idx_meeting_events_user'

  create_table 'meeting_individual_results', force: true do |t|
    t.integer  'lock_version',                                                              default: 0
    t.integer  'rank',                                                                      default: 0
    t.boolean  'is_play_off',                                                               default: false
    t.boolean  'is_out_of_race',                                                            default: false
    t.boolean  'is_disqualified',                                                           default: false
    t.decimal  'standard_points',                            precision: 10, scale: 2, default: 0.0
    t.decimal  'meeting_individual_points',                  precision: 10, scale: 2, default: 0.0
    t.integer  'minutes',                       limit: 3,                                default: 0
    t.integer  'seconds',                       limit: 2,                                default: 0
    t.integer  'hundreds',                      limit: 2,                                default: 0
    t.integer  'meeting_program_id'
    t.integer  'swimmer_id'
    t.integer  'team_id'
    t.integer  'badge_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'disqualification_code_type_id'
    t.decimal  'goggle_cup_points',                          precision: 10, scale: 2, default: 0.0
    t.decimal  'reaction_time',                              precision: 5,  scale: 2, default: 0.0
    t.decimal  'team_points',                                precision: 10, scale: 2, default: 0.0
    t.integer  'team_affiliation_id'
    t.boolean  'is_personal_best',                                                          default: false, null: false
    t.boolean  'is_season_type_best',                                                       default: false, null: false
  end

  add_index 'meeting_individual_results', ['badge_id'], name: 'fk_meeting_individual_results_badges'
  add_index 'meeting_individual_results', ['disqualification_code_type_id'], name: 'idx_mir_disqualification_code_type'
  add_index 'meeting_individual_results', ['meeting_program_id'], name: 'fk_meeting_individual_results_meeting_programs'
  add_index 'meeting_individual_results', ['swimmer_id'], name: 'fk_meeting_individual_results_swimmers'
  add_index 'meeting_individual_results', ['team_affiliation_id'], name: 'fk_meeting_individual_results_team_affiliations'
  add_index 'meeting_individual_results', ['team_id'], name: 'fk_meeting_individual_results_teams'
  add_index 'meeting_individual_results', ['user_id'], name: 'idx_mir_user'

  create_table 'meeting_programs', force: true do |t|
    t.integer  'lock_version', default: 0
    t.integer  'event_order', limit: 3, default: 0
    t.integer  'category_type_id'
    t.integer  'gender_type_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean  'is_autofilled',                 default: false
    t.boolean  'is_out_of_race',                default: false
    t.time     'begin_time'
    t.integer  'meeting_event_id'
    t.integer  'pool_type_id'
    t.integer  'time_standard_id'
  end

  add_index 'meeting_programs', ['category_type_id'], name: 'meeting_category_type'
  add_index 'meeting_programs', ['event_order'], name: 'meeting_order'
  add_index 'meeting_programs', ['gender_type_id'], name: 'meeting_gender_type'
  add_index 'meeting_programs', ['meeting_event_id'], name: 'fk_meeting_programs_meeting_events'
  add_index 'meeting_programs', ['pool_type_id'], name: 'fk_meeting_programs_pool_types'
  add_index 'meeting_programs', ['time_standard_id'], name: 'fk_meeting_programs_time_standards'
  add_index 'meeting_programs', ['user_id'], name: 'idx_meeting_programs_user'

  create_table 'meeting_relay_results', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'rank',                                                                       default: 0
    t.boolean  'is_play_off',                                                                default: false
    t.boolean  'is_out_of_race',                                                             default: false
    t.boolean  'is_disqualified',                                                            default: false
    t.decimal  'standard_points',                             precision: 10, scale: 2, default: 0.0
    t.decimal  'meeting_points',                              precision: 10, scale: 2, default: 0.0
    t.integer  'minutes',                       limit: 3,                                 default: 0
    t.integer  'seconds',                       limit: 2,                                 default: 0
    t.integer  'hundreds',                      limit: 2,                                 default: 0
    t.integer  'team_id'
    t.integer  'user_id'
    t.integer  'meeting_program_id'
    t.integer  'disqualification_code_type_id'
    t.string   'relay_header', limit: 60, default: ''
    t.decimal  'reaction_time', precision: 5, scale: 2, default: 0.0
    t.integer  'entry_minutes',                 limit: 3
    t.integer  'entry_seconds',                 limit: 2
    t.integer  'entry_hundreds',                limit: 2
    t.integer  'team_affiliation_id'
    t.integer  'entry_time_type_id'
  end

  add_index 'meeting_relay_results', ['disqualification_code_type_id'], name: 'idx_mrr_disqualification_code_type'
  add_index 'meeting_relay_results', ['entry_time_type_id'], name: 'fk_meeting_relay_results_entry_time_types'
  add_index 'meeting_relay_results', %w[meeting_program_id rank], name: 'results_x_relay'
  add_index 'meeting_relay_results', ['team_affiliation_id'], name: 'fk_meeting_relay_results_team_affiliations'
  add_index 'meeting_relay_results', ['team_id'], name: 'fk_meeting_relay_results_teams'
  add_index 'meeting_relay_results', ['user_id'], name: 'idx_mrr_user'

  create_table 'meeting_relay_swimmers', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'relay_order', limit: 3, default: 0
    t.integer  'swimmer_id'
    t.integer  'badge_id'
    t.integer  'stroke_type_id'
    t.integer  'user_id'
    t.decimal  'reaction_time', precision: 5, scale: 2, default: 0.0
    t.integer  'minutes',                 limit: 3,                               default: 0
    t.integer  'seconds',                 limit: 2,                               default: 0
    t.integer  'hundreds',                limit: 2,                               default: 0
    t.integer  'meeting_relay_result_id'
  end

  add_index 'meeting_relay_swimmers', ['badge_id'], name: 'fk_meeting_relay_swimmers_badges'
  add_index 'meeting_relay_swimmers', ['meeting_relay_result_id'], name: 'fk_meeting_relay_swimmers_meeting_relay_results'
  add_index 'meeting_relay_swimmers', ['relay_order'], name: 'relay_order'
  add_index 'meeting_relay_swimmers', ['stroke_type_id'], name: 'fk_meeting_relay_swimmers_stroke_types'
  add_index 'meeting_relay_swimmers', ['swimmer_id'], name: 'fk_meeting_relay_swimmers_swimmers'
  add_index 'meeting_relay_swimmers', ['user_id'], name: 'idx_meeting_relay_swimmers_user'

  create_table 'meeting_reservations', force: true do |t|
    t.integer  'meeting_id'
    t.integer  'team_id'
    t.integer  'swimmer_id'
    t.integer  'badge_id'
    t.integer  'meeting_event_id'
    t.integer  'user_id'
    t.integer  'suggested_minutes',  limit: 3
    t.integer  'suggested_seconds',  limit: 2
    t.integer  'suggested_hundreds', limit: 2
    t.text     'notes'
    t.datetime 'created_at',                      null: false
    t.datetime 'updated_at',                      null: false
  end

  add_index 'meeting_reservations', ['badge_id'], name: 'index_meeting_reservations_on_badge_id'
  add_index 'meeting_reservations', ['meeting_event_id'], name: 'index_meeting_reservations_on_meeting_event_id'
  add_index 'meeting_reservations', ['meeting_id'], name: 'index_meeting_reservations_on_meeting_id'
  add_index 'meeting_reservations', ['swimmer_id'], name: 'index_meeting_reservations_on_swimmer_id'
  add_index 'meeting_reservations', ['team_id'], name: 'index_meeting_reservations_on_team_id'
  add_index 'meeting_reservations', ['user_id'], name: 'index_meeting_reservations_on_user_id'

  create_table 'meeting_sessions', force: true do |t|
    t.integer  'lock_version',                    default: 0
    t.integer  'session_order', limit: 2, default: 0
    t.date     'scheduled_date'
    t.time     'warm_up_time'
    t.time     'begin_time'
    t.text     'notes'
    t.integer  'meeting_id'
    t.integer  'swimming_pool_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'description', limit: 100
    t.boolean  'is_autofilled', default: false
    t.integer  'day_part_type_id'
  end

  add_index 'meeting_sessions', ['day_part_type_id'], name: 'fk_meeting_sessions_day_part_types'
  add_index 'meeting_sessions', ['meeting_id'], name: 'fk_meeting_sessions_meetings'
  add_index 'meeting_sessions', ['scheduled_date'], name: 'index_meeting_sessions_on_scheduled_date'
  add_index 'meeting_sessions', ['swimming_pool_id'], name: 'fk_meeting_sessions_swimming_pools'
  add_index 'meeting_sessions', ['user_id'], name: 'idx_meeting_sessions_user'

  create_table 'meeting_team_scores', force: true do |t|
    t.integer  'lock_version', default: 0
    t.decimal  'sum_individual_points',     precision: 10, scale: 2, default: 0.0
    t.decimal  'sum_relay_points',          precision: 10, scale: 2, default: 0.0
    t.integer  'team_id'
    t.integer  'meeting_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'rank', default: 0
    t.integer  'user_id'
    t.decimal  'sum_team_points',           precision: 10, scale: 2, default: 0.0
    t.decimal  'meeting_individual_points', precision: 10, scale: 2, default: 0.0
    t.decimal  'meeting_relay_points',      precision: 10, scale: 2, default: 0.0
    t.decimal  'meeting_team_points',       precision: 10, scale: 2, default: 0.0
    t.decimal  'season_individual_points',  precision: 10, scale: 2, default: 0.0
    t.decimal  'season_relay_points',       precision: 10, scale: 2, default: 0.0
    t.decimal  'season_team_points',        precision: 10, scale: 2, default: 0.0
    t.integer  'season_id'
    t.integer  'team_affiliation_id'
  end

  add_index 'meeting_team_scores', %w[meeting_id team_id], name: 'teams_x_meeting'
  add_index 'meeting_team_scores', ['season_id'], name: 'fk_meeting_team_scores_seasons'
  add_index 'meeting_team_scores', ['team_affiliation_id'], name: 'fk_meeting_team_scores_team_affiliations'
  add_index 'meeting_team_scores', ['team_id'], name: 'fk_meeting_team_scores_teams'
  add_index 'meeting_team_scores', ['user_id'], name: 'idx_meeting_team_scores_user'

  create_table 'meetings', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'description', limit: 100
    t.date     'entry_deadline'
    t.boolean  'has_warm_up_pool',                                         default: false
    t.boolean  'is_under_25_admitted',                                     default: false
    t.string   'reference_phone',                      limit: 40
    t.string   'reference_e_mail',                     limit: 50
    t.string   'reference_name',                       limit: 50
    t.text     'notes'
    t.boolean  'has_invitation',                                           default: false
    t.boolean  'has_start_list',                                           default: false
    t.boolean  'are_results_acquired',                                     default: false
    t.integer  'max_individual_events', limit: 1, default: 2
    t.string   'configuration_file'
    t.integer  'edition', limit: 3, default: 0
    t.integer  'season_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean  'is_autofilled', default: false
    t.date     'header_date'
    t.string   'code',                                 limit: 50
    t.string   'header_year',                          limit: 9
    t.integer  'max_individual_events_per_session',    limit: 2, default: 2
    t.boolean  'is_out_of_season', default: false
    t.integer  'edition_type_id'
    t.integer  'timing_type_id'
    t.integer  'individual_score_computation_type_id'
    t.integer  'relay_score_computation_type_id'
    t.integer  'team_score_computation_type_id'
    t.integer  'meeting_score_computation_type_id'
    t.text     'invitation', limit: 16_777_215
    t.boolean  'is_confirmed', default: false, null: false
  end

  add_index 'meetings', %w[code edition], name: 'idx_meetings_code'
  add_index 'meetings', ['edition_type_id'], name: 'fk_meetings_edition_types'
  add_index 'meetings', ['entry_deadline'], name: 'index_meetings_on_entry_deadline'
  add_index 'meetings', ['header_date'], name: 'idx_meetings_header_date'
  add_index 'meetings', ['individual_score_computation_type_id'], name: 'fk_meetings_score_individual_score_computation_types'
  add_index 'meetings', ['meeting_score_computation_type_id'], name: 'fk_meetings_score_meeting_score_computation_types'
  add_index 'meetings', ['relay_score_computation_type_id'], name: 'fk_meetings_score_relay_score_computation_types'
  add_index 'meetings', ['season_id'], name: 'fk_meetings_seasons'
  add_index 'meetings', ['team_score_computation_type_id'], name: 'fk_meetings_score_team_score_computation_types'
  add_index 'meetings', ['timing_type_id'], name: 'fk_meetings_timing_types'
  add_index 'meetings', ['user_id'], name: 'idx_meetings_user'

  create_table 'movement_scope_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 1
  end

  add_index 'movement_scope_types', ['code'], name: 'index_movement_scope_types_on_code', unique: true

  create_table 'movement_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 1
  end

  add_index 'movement_types', ['code'], name: 'index_movement_types_on_code', unique: true

  create_table 'news_feeds', force: true do |t|
    t.string   'title', limit: 150
    t.text     'body'
    t.boolean  'is_read',                           default: false
    t.boolean  'is_friend_activity',                default: false
    t.boolean  'is_achievement',                    default: false
    t.integer  'user_id'
    t.integer  'friend_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'news_feeds', ['user_id'], name: 'idx_news_feeds_user'

  create_table 'passage_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code',             limit: 6
    t.integer  'length_in_meters', limit: 3
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'passage_types', ['code'], name: 'index_passage_types_on_code', unique: true

  create_table 'passages', force: true do |t|
    t.integer  'lock_version', default: 0
    t.integer  'minutes',                      limit: 3,                               default: 0
    t.integer  'seconds',                      limit: 2,                               default: 0
    t.integer  'hundreds',                     limit: 2,                               default: 0
    t.integer  'meeting_program_id'
    t.integer  'passage_type_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.decimal  'reaction_time', precision: 5, scale: 2
    t.integer  'stroke_cycles',                limit: 3
    t.integer  'not_swam_part_seconds',        limit: 2
    t.integer  'not_swam_part_hundreds',       limit: 2
    t.integer  'not_swam_kick_number',         limit: 2
    t.integer  'breath_number',                limit: 3
    t.integer  'position',                     limit: 3
    t.integer  'minutes_from_start',           limit: 3
    t.integer  'seconds_from_start',           limit: 2
    t.integer  'hundreds_from_start',          limit: 2
    t.boolean  'is_native_from_start', default: false
    t.integer  'meeting_individual_result_id'
    t.integer  'meeting_entry_id'
    t.integer  'swimmer_id'
    t.integer  'team_id'
  end

  add_index 'passages', ['meeting_entry_id'], name: 'idx_passages_meeting_entry'
  add_index 'passages', ['meeting_individual_result_id'], name: 'idx_passages_meeting_individual_result'
  add_index 'passages', ['meeting_program_id'], name: 'passages_x_badges'
  add_index 'passages', ['passage_type_id'], name: 'fk_passages_passage_types'
  add_index 'passages', ['swimmer_id'], name: 'idx_passages_swimmer'
  add_index 'passages', ['team_id'], name: 'idx_passages_team'
  add_index 'passages', ['user_id'], name: 'idx_passages_user'

  create_table 'pool_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code',                     limit: 3
    t.integer  'length_in_meters',         limit: 3
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean  'is_suitable_for_meetings', default: true
  end

  add_index 'pool_types', ['code'], name: 'index_pool_types_on_code', unique: true

  create_table 'presence_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code',         limit: 1
    t.integer  'value',        limit: 3
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'presence_types', ['code'], name: 'index_presence_types_on_code', unique: true

  create_table 'rails_admin_histories', force: true do |t|
    t.text     'message'
    t.string   'username'
    t.integer  'item'
    t.string   'table'
    t.integer  'month',      limit: 2
    t.integer  'year',       limit: 8
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'rails_admin_histories', %w[item table month year], name: 'index_rails_admin_histories'

  create_table 'record_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code', limit: 3
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean  'is_for_swimmers',              default: false
    t.boolean  'is_for_teams',                 default: false
    t.boolean  'is_for_seasons',               default: false
  end

  add_index 'record_types', ['code'], name: 'index_record_types_on_code', unique: true

  create_table 'score_computation_type_rows', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'class_name',                limit: 100
    t.string   'method_name',               limit: 100
    t.decimal  'default_score', precision: 10, scale: 2, default: 0.0
    t.integer  'score_computation_type_id'
    t.integer  'score_mapping_type_id'
    t.integer  'computation_order', limit: 8, default: 0
    t.integer  'position_limit', default: 0
  end

  add_index 'score_computation_type_rows', ['computation_order'], name: 'idx_score_computation_type_rows_computation_order'
  add_index 'score_computation_type_rows', ['score_computation_type_id'], name: 'fk_score_computation_type_rows_score_computation_types'
  add_index 'score_computation_type_rows', ['score_mapping_type_id'], name: 'idx_score_computation_type_rows_score_mapping_type'

  create_table 'score_computation_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 6
  end

  add_index 'score_computation_types', ['code'], name: 'index_score_computation_types_on_code', unique: true

  create_table 'score_mapping_type_rows', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'position', limit: 8, default: 0
    t.decimal  'score', precision: 10, scale: 2, default: 0.0
    t.integer  'score_mapping_type_id'
  end

  add_index 'score_mapping_type_rows', ['score_mapping_type_id'], name: 'idx_score_mapping_type_rows_score_mapping_type'

  create_table 'score_mapping_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 6
  end

  add_index 'score_mapping_types', ['code'], name: 'index_score_mapping_types_on_code', unique: true

  create_table 'season_personal_standards', force: true do |t|
    t.integer  'lock_version', default: 0
    t.integer  'minutes',       limit: 3, default: 0, null: false
    t.integer  'seconds',       limit: 2, default: 0, null: false
    t.integer  'hundreds',      limit: 2, default: 0, null: false
    t.integer  'season_id'
    t.integer  'swimmer_id'
    t.integer  'event_type_id'
    t.integer  'pool_type_id'
    t.datetime 'created_at',                                null: false
    t.datetime 'updated_at',                                null: false
  end

  create_table 'season_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code',               limit: 10
    t.string   'description',        limit: 100
    t.string   'short_name',         limit: 40
    t.integer  'federation_type_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'season_types', ['code'], name: 'index_season_types_on_code', unique: true
  add_index 'season_types', ['federation_type_id'], name: 'fk_season_types_federation_types'

  create_table 'seasons', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'description', limit: 100
    t.date     'begin_date'
    t.date     'end_date'
    t.integer  'season_type_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'header_year',         limit: 9
    t.integer  'edition',             limit: 3, default: 0
    t.integer  'edition_type_id'
    t.integer  'timing_type_id'
    t.text     'rules', limit: 16_777_215
    t.boolean  'has_individual_rank', default: true
  end

  add_index 'seasons', ['begin_date'], name: 'index_seasons_on_begin_date'
  add_index 'seasons', ['edition_type_id'], name: 'fk_seasons_edition_types'
  add_index 'seasons', ['season_type_id'], name: 'fk_seasons_season_types'
  add_index 'seasons', ['timing_type_id'], name: 'fk_seasons_timing_types'

  create_table 'sessions', force: true do |t|
    t.string   'session_id'
    t.text     'data'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'sessions', ['session_id'], name: 'index_sessions_on_session_id'
  add_index 'sessions', ['updated_at'], name: 'index_sessions_on_updated_at'

  create_table 'shower_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code', limit: 3
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'shower_types', ['code'], name: 'index_shower_types_on_code', unique: true

  create_table 'stroke_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code', limit: 2
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean  'is_eventable', default: false
  end

  add_index 'stroke_types', ['code'], name: 'index_stroke_types_on_code', unique: true
  add_index 'stroke_types', ['is_eventable'], name: 'idx_is_eventable'

  create_table 'swimmer_level_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code',           limit: 5
    t.integer  'level',          limit: 3, default: 0
    t.integer  'achievement_id'
  end

  add_index 'swimmer_level_types', ['achievement_id'], name: 'idx_swimmer_level_types_achievement'
  add_index 'swimmer_level_types', ['code'], name: 'index_swimmer_level_types_on_code', unique: true

  create_table 'swimmers', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'last_name',          limit: 50
    t.string   'first_name',         limit: 50
    t.integer  'year_of_birth', default: 1900
    t.string   'phone_mobile',       limit: 40
    t.string   'phone_number',       limit: 40
    t.string   'e_mail',             limit: 100
    t.string   'nickname',           limit: 25, default: ''
    t.integer  'associated_user_id', limit: 8
    t.integer  'gender_type_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'complete_name', limit: 100
    t.boolean  'is_year_guessed', default: false
  end

  add_index 'swimmers', ['associated_user_id'], name: 'index_swimmers_on_associated_user_id'
  add_index 'swimmers', %w[complete_name year_of_birth], name: 'name_and_year', unique: true
  add_index 'swimmers', ['complete_name'], name: 'index_swimmers_on_complete_name'
  add_index 'swimmers', ['gender_type_id'], name: 'fk_swimmers_gender_types'
  add_index 'swimmers', %w[last_name first_name], name: 'full_name'
  add_index 'swimmers', ['nickname'], name: 'index_swimmers_on_nickname'
  add_index 'swimmers', ['user_id'], name: 'idx_swimmers_user'

  create_table 'swimming_pool_reviews', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'title', limit: 100
    t.text     'entry_text'
    t.integer  'user_id'
    t.integer  'swimming_pool_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'swimming_pool_reviews', ['swimming_pool_id'], name: 'fk_swimming_pool_reviews_swimming_pools'
  add_index 'swimming_pool_reviews', ['title'], name: 'index_swimming_pool_reviews_on_title'
  add_index 'swimming_pool_reviews', ['user_id'], name: 'idx_swimming_pool_reviews_user'

  create_table 'swimming_pools', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'name',                   limit: 100
    t.string   'address',                limit: 100
    t.string   'zip',                    limit: 6
    t.string   'nick_name',              limit: 50
    t.string   'phone_number',           limit: 40
    t.string   'fax_number',             limit: 40
    t.string   'e_mail',                 limit: 100
    t.string   'contact_name',           limit: 100
    t.string   'maps_uri'
    t.integer  'lanes_number', limit: 2, default: 8
    t.boolean  'has_multiple_pools',                    default: false
    t.boolean  'has_open_area',                         default: false
    t.boolean  'has_bar',                               default: false
    t.boolean  'has_restaurant_service',                default: false
    t.boolean  'has_gym_area',                          default: false
    t.boolean  'has_children_area',                     default: false
    t.text     'notes'
    t.integer  'city_id'
    t.integer  'pool_type_id'
    t.integer  'shower_type_id'
    t.integer  'hair_dryer_type_id'
    t.integer  'locker_cabinet_type_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'swimming_pools', ['city_id'], name: 'fk_swimming_pools_cities'
  add_index 'swimming_pools', ['hair_dryer_type_id'], name: 'fk_swimming_pools_hair_dryer_types'
  add_index 'swimming_pools', ['locker_cabinet_type_id'], name: 'fk_swimming_pools_locker_cabinet_types'
  add_index 'swimming_pools', ['name'], name: 'index_swimming_pools_on_name'
  add_index 'swimming_pools', ['nick_name'], name: 'index_swimming_pools_on_nick_name', unique: true
  add_index 'swimming_pools', ['pool_type_id'], name: 'fk_swimming_pools_pool_types'
  add_index 'swimming_pools', ['shower_type_id'], name: 'fk_swimming_pools_shower_types'
  add_index 'swimming_pools', ['user_id'], name: 'idx_swimming_pools_user'

  create_table 'taggings', force: true do |t|
    t.integer  'tag_id'
    t.integer  'taggable_id'
    t.string   'taggable_type'
    t.integer  'tagger_id'
    t.string   'tagger_type'
    t.string   'context', limit: 128
    t.datetime 'created_at'
  end

  add_index 'taggings', %w[tag_id taggable_id taggable_type context tagger_id tagger_type], name: 'taggings_idx', unique: true
  add_index 'taggings', %w[taggable_id taggable_type context], name: 'index_taggings_on_taggable_id_and_taggable_type_and_context'

  create_table 'tags', force: true do |t|
    t.string  'name'
    t.integer 'taggings_count', default: 0
  end

  add_index 'tags', ['name'], name: 'index_tags_on_name', unique: true

  create_table 'team_affiliations', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'number',                    limit: 20
    t.string   'name',                      limit: 100
    t.boolean  'must_calculate_goggle_cup', default: false
    t.integer  'team_id'
    t.integer  'season_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.boolean  'is_autofilled', default: false
  end

  add_index 'team_affiliations', ['name'], name: 'index_team_affiliations_on_name'
  add_index 'team_affiliations', ['number'], name: 'index_team_affiliations_on_number'
  add_index 'team_affiliations', %w[season_id team_id], name: 'uk_team_affiliations_seasons_teams', unique: true
  add_index 'team_affiliations', ['team_id'], name: 'fk_team_affiliations_teams'
  add_index 'team_affiliations', ['user_id'], name: 'idx_team_affiliations_user'

  create_table 'team_managers', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'team_affiliation_id'
    t.integer  'user_id'
  end

  add_index 'team_managers', %w[team_affiliation_id user_id], name: 'team_manager_with_affiliation', unique: true
  add_index 'team_managers', ['team_affiliation_id'], name: 'index_team_managers_on_team_affiliation_id'
  add_index 'team_managers', ['user_id'], name: 'index_team_managers_on_user_id'

  create_table 'team_passage_templates', force: true do |t|
    t.integer  'lock_version', default: 0
    t.integer  'part_order', limit: 3, default: 0
    t.boolean  'has_subtotal',                         default: false
    t.boolean  'has_cycle_count',                      default: false
    t.boolean  'has_breath_count',                     default: false
    t.boolean  'has_non_swam_part',                    default: false
    t.boolean  'has_non_swam_kick_count',              default: false
    t.boolean  'has_passage_position',                 default: false
    t.integer  'team_id'
    t.integer  'event_type_id'
    t.integer  'pool_type_id'
    t.integer  'passage_type_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'team_passage_templates', ['event_type_id'], name: 'idx_team_passage_templates_event_type'
  add_index 'team_passage_templates', ['passage_type_id'], name: 'idx_team_passage_templates_passage_type'
  add_index 'team_passage_templates', ['pool_type_id'], name: 'idx_team_passage_templates_pool_type'
  add_index 'team_passage_templates', ['team_id'], name: 'idx_team_passage_templates_team'
  add_index 'team_passage_templates', ['user_id'], name: 'idx_team_passage_templates_user'

  create_table 'teams', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'name',            limit: 60
    t.string   'editable_name',   limit: 60
    t.string   'address',         limit: 100
    t.string   'zip',             limit: 6
    t.string   'phone_mobile',    limit: 40
    t.string   'phone_number',    limit: 40
    t.string   'fax_number',      limit: 40
    t.string   'e_mail',          limit: 100
    t.string   'contact_name',    limit: 100
    t.text     'notes'
    t.text     'name_variations'
    t.integer  'city_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'home_page_url', limit: 150
  end

  add_index 'teams', ['city_id'], name: 'fk_teams_cities'
  add_index 'teams', ['editable_name'], name: 'index_teams_on_editable_name'
  add_index 'teams', ['name'], name: 'index_teams_on_name'
  add_index 'teams', ['user_id'], name: 'idx_teams_user'

  create_table 'time_standards', force: true do |t|
    t.integer  'lock_version',                  default: 0
    t.integer  'minutes',          limit: 3, default: 0
    t.integer  'seconds',          limit: 2, default: 0
    t.integer  'hundreds',         limit: 2, default: 0
    t.integer  'season_id'
    t.integer  'gender_type_id'
    t.integer  'pool_type_id'
    t.integer  'event_type_id'
    t.integer  'category_type_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'time_standards', ['category_type_id'], name: 'fk_time_standards_category_types'
  add_index 'time_standards', ['event_type_id'], name: 'fk_time_standards_event_types'
  add_index 'time_standards', ['gender_type_id'], name: 'fk_time_standards_gender_types'
  add_index 'time_standards', ['pool_type_id'], name: 'fk_time_standards_pool_types'
  add_index 'time_standards', ['season_id'], name: 'fk_time_standards_seasons'

  create_table 'timing_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'code', limit: 1
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'timing_types', ['code'], name: 'index_timing_types_on_code', unique: true

  create_table 'training_mode_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code', limit: 5
  end

  add_index 'training_mode_types', ['code'], name: 'index_training_mode_types_on_code', unique: true

  create_table 'training_rows', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'part_order',            limit: 3, default: 0
    t.integer  'times',                 limit: 3, default: 0
    t.integer  'distance',                           default: 0
    t.integer  'start_and_rest',                     default: 0
    t.integer  'pause',                              default: 0
    t.integer  'training_id'
    t.integer  'exercise_id'
    t.integer  'training_step_type_id'
    t.integer  'group_id',              limit: 3, default: 0
    t.integer  'group_times',           limit: 3, default: 0
    t.integer  'group_start_and_rest',               default: 0
    t.integer  'group_pause',                        default: 0
    t.integer  'arm_aux_type_id'
    t.integer  'kick_aux_type_id'
    t.integer  'body_aux_type_id'
    t.integer  'breath_aux_type_id'
  end

  add_index 'training_rows', ['arm_aux_type_id'], name: 'fk_training_rows_arm_aux_types'
  add_index 'training_rows', ['body_aux_type_id'], name: 'fk_training_rows_body_aux_types'
  add_index 'training_rows', ['breath_aux_type_id'], name: 'fk_training_rows_breath_aux_types'
  add_index 'training_rows', ['exercise_id'], name: 'fk_training_exercises'
  add_index 'training_rows', %w[group_id part_order], name: 'index_training_rows_on_group_id_and_part_order'
  add_index 'training_rows', ['kick_aux_type_id'], name: 'fk_training_rows_kick_aux_types'
  add_index 'training_rows', %w[training_id part_order], name: 'idx_training_rows_part_order'
  add_index 'training_rows', ['training_step_type_id'], name: 'fk_training_rows_training_step_types'

  create_table 'training_step_types', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'code',         limit: 1
    t.integer  'step_order',   limit: 3, default: 0
  end

  add_index 'training_step_types', ['code'], name: 'index_training_step_types_on_code', unique: true
  add_index 'training_step_types', ['step_order'], name: 'index_training_step_types_on_step_order'

  create_table 'trainings', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'title', limit: 100, default: ''
    t.text     'description'
    t.integer  'user_id'
    t.integer  'min_swimmer_level', limit: 3,   default: 0
    t.integer  'max_swimmer_level', limit: 3,   default: 0
  end

  add_index 'trainings', ['title'], name: 'index_trainings_on_title', unique: true
  add_index 'trainings', ['user_id'], name: 'idx_trainings_user'

  create_table 'user_achievements', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'user_id'
    t.integer  'achievement_id'
  end

  add_index 'user_achievements', %w[user_id achievement_id], name: 'index_user_achievements_on_user_id_and_achievement_id', unique: true

  create_table 'user_results', force: true do |t|
    t.integer  'lock_version', default: 0
    t.decimal  'standard_points',                             precision: 10, scale: 2, default: 0.0
    t.decimal  'meeting_points',                              precision: 10, scale: 2, default: 0.0
    t.integer  'rank', limit: 8, default: 0
    t.boolean  'is_disqualified', default: false
    t.integer  'minutes',                       limit: 3,                                 default: 0
    t.integer  'seconds',                       limit: 2,                                 default: 0
    t.integer  'hundreds',                      limit: 2,                                 default: 0
    t.integer  'swimmer_id'
    t.integer  'category_type_id'
    t.integer  'pool_type_id'
    t.integer  'meeting_individual_result_id'
    t.integer  'user_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'disqualification_code_type_id'
    t.string   'description', limit: 60, default: ''
    t.date     'event_date'
    t.decimal  'reaction_time', precision: 10, scale: 2, default: 0.0
    t.integer  'event_type_id'
  end

  add_index 'user_results', ['category_type_id'], name: 'fk_user_results_category_types'
  add_index 'user_results', ['disqualification_code_type_id'], name: 'idx_user_results_disqualification_code_type'
  add_index 'user_results', ['event_type_id'], name: 'fk_user_results_event_types'
  add_index 'user_results', %w[meeting_individual_result_id rank], name: 'meeting_id_rank'
  add_index 'user_results', ['pool_type_id'], name: 'fk_user_results_pool_types'
  add_index 'user_results', ['swimmer_id'], name: 'fk_user_results_swimmers'
  add_index 'user_results', ['user_id'], name: 'idx_user_results_user'

  create_table 'user_swimmer_confirmations', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'swimmer_id'
    t.integer  'user_id'
    t.integer  'confirmator_id'
  end

  add_index 'user_swimmer_confirmations', ['confirmator_id'], name: 'index_user_swimmer_confirmations_on_confirmator_id'
  add_index 'user_swimmer_confirmations', %w[user_id swimmer_id confirmator_id], name: 'user_swimmer_confirmator', unique: true

  create_table 'user_training_rows', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer  'part_order',            limit: 3, default: 0
    t.integer  'times',                 limit: 3, default: 0
    t.integer  'distance',                           default: 0
    t.integer  'start_and_rest',                     default: 0
    t.integer  'pause',                              default: 0
    t.integer  'group_id',              limit: 3, default: 0
    t.integer  'group_times',           limit: 3, default: 0
    t.integer  'group_start_and_rest',               default: 0
    t.integer  'group_pause',                        default: 0
    t.integer  'user_training_id'
    t.integer  'exercise_id'
    t.integer  'training_step_type_id'
    t.integer  'arm_aux_type_id'
    t.integer  'kick_aux_type_id'
    t.integer  'body_aux_type_id'
    t.integer  'breath_aux_type_id'
  end

  add_index 'user_training_rows', ['arm_aux_type_id'], name: 'idx_user_training_rows_arm_aux_type'
  add_index 'user_training_rows', ['body_aux_type_id'], name: 'idx_user_training_rows_body_aux_type'
  add_index 'user_training_rows', ['breath_aux_type_id'], name: 'idx_user_training_rows_breath_aux_type'
  add_index 'user_training_rows', ['exercise_id'], name: 'idx_user_training_rows_exercise'
  add_index 'user_training_rows', %w[group_id part_order], name: 'index_user_training_rows_on_group_id_and_part_order'
  add_index 'user_training_rows', ['kick_aux_type_id'], name: 'idx_user_training_rows_kick_aux_type'
  add_index 'user_training_rows', ['training_step_type_id'], name: 'idx_user_training_rows_training_step_type'
  add_index 'user_training_rows', %w[user_training_id part_order], name: 'idx_user_training_rows_part_order'

  create_table 'user_training_stories', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.date     'swam_date'
    t.integer  'total_training_time', limit: 3, default: 0
    t.text     'notes'
    t.integer  'user_training_id'
    t.integer  'swimming_pool_id'
    t.integer  'swimmer_level_type_id'
    t.integer  'user_id'
  end

  add_index 'user_training_stories', ['swimmer_level_type_id'], name: 'idx_user_training_stories_swimmer_level_type'
  add_index 'user_training_stories', ['swimming_pool_id'], name: 'idx_user_training_stories_swimming_pool'
  add_index 'user_training_stories', ['user_id'], name: 'idx_user_training_stories_user'
  add_index 'user_training_stories', %w[user_training_id swam_date], name: 'index_user_training_stories_on_user_training_id_and_swam_date'

  create_table 'user_trainings', force: true do |t|
    t.integer  'lock_version', default: 0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'description', limit: 250, default: ''
    t.integer  'user_id'
  end

  add_index 'user_trainings', %w[user_id description], name: 'index_user_trainings_on_user_id_and_description'

  create_table 'users', force: true do |t|
    t.integer  'lock_version', default: 0
    t.string   'name'
    t.string   'description', limit: 100
    t.integer  'swimmer_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string   'email',                                          default: ''
    t.string   'encrypted_password',                             default: ''
    t.string   'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.integer  'sign_in_count', default: 0
    t.datetime 'current_sign_in_at'
    t.datetime 'last_sign_in_at'
    t.string   'current_sign_in_ip'
    t.string   'last_sign_in_ip'
    t.string   'confirmation_token'
    t.datetime 'confirmed_at'
    t.datetime 'confirmation_sent_at'
    t.string   'unconfirmed_email'
    t.integer  'failed_attempts', default: 0
    t.string   'unlock_token'
    t.datetime 'locked_at'
    t.boolean  'use_email_data_updates_notify',                  default: false
    t.boolean  'use_email_achievements_notify',                  default: false
    t.boolean  'use_email_newsletter_notify',                    default: false
    t.boolean  'use_email_community_notify',                     default: false
    t.string   'avatar_resource_filename', limit: 250
    t.integer  'swimmer_level_type_id'
    t.integer  'coach_level_type_id'
    t.string   'authentication_token'
    t.integer  'outstanding_goggle_score_bias',                  default: 800
    t.integer  'outstanding_standard_score_bias',                default: 800
    t.string   'last_name',                       limit: 50
    t.string   'first_name',                      limit: 50
    t.integer  'year_of_birth', default: 1900
    t.integer  'facebook_uid',                    limit: 8
    t.integer  'goggle_uid',                      limit: 8
    t.integer  'twitter_uid',                     limit: 8
  end

  add_index 'users', ['authentication_token'], name: 'index_users_on_authentication_token', unique: true
  add_index 'users', ['coach_level_type_id'], name: 'idx_users_coach_level_type'
  add_index 'users', ['confirmation_token'], name: 'index_users_on_confirmation_token', unique: true
  add_index 'users', ['email'], name: 'index_users_on_email', unique: true
  add_index 'users', %w[last_name first_name year_of_birth], name: 'full_name'
  add_index 'users', ['name'], name: 'index_users_on_name', unique: true
  add_index 'users', ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
  add_index 'users', ['swimmer_id'], name: 'idx_users_swimmer'
  add_index 'users', ['swimmer_level_type_id'], name: 'idx_users_swimmer_level_type'
  add_index 'users', ['unlock_token'], name: 'index_users_on_unlock_token', unique: true

  create_table 'votes', force: true do |t|
    t.integer  'votable_id'
    t.string   'votable_type'
    t.integer  'voter_id'
    t.string   'voter_type'
    t.boolean  'vote_flag'
    t.string   'vote_scope'
    t.integer  'vote_weight'
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'votes', %w[votable_id votable_type vote_scope], name: 'index_votes_on_votable_id_and_votable_type_and_vote_scope'
  add_index 'votes', %w[votable_id votable_type], name: 'index_votes_on_votable_id_and_votable_type'
  add_index 'votes', %w[voter_id voter_type vote_scope], name: 'index_votes_on_voter_id_and_voter_type_and_vote_scope'
  add_index 'votes', %w[voter_id voter_type], name: 'index_votes_on_voter_id_and_voter_type'
end
