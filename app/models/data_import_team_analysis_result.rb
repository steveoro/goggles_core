# encoding: utf-8


class DataImportTeamAnalysisResult < ApplicationRecord
  belongs_to            :data_import_session
  validates_associated  :data_import_session

  belongs_to :season, foreign_key: "desired_season_id"
  belongs_to :team,   foreign_key: "chosen_team_id"

#  attr_accessible :analysis_log_text, :sql_text, :searched_team_name,
#                  :desired_season_id, :chosen_team_id,
#                  :team_match_name, :team_match_score,
#                  :best_match_name, :best_match_score

  validates_length_of       :searched_team_name, maximum: 60
  validates_length_of       :team_match_name, maximum: 60
  validates_length_of       :best_match_name, maximum: 60
  #-- -------------------------------------------------------------------------
  #++

  # +true+ if we have a perfect match with equal names (and no suggested actions).
  def is_a_perfect_match
    ( self.chosen_team_id.to_i > 0 ) &&
    ( self.searched_team_name == self.team_match_name ) &&
    ( self.searched_team_name == self.best_match_name ) &&
    ( self.best_match_score >= 0.99 )

  end

  # +true+ if one of the suggested action for this result
  # is the creation of a new "team alias" row.
  def can_insert_alias
    # We can create a new team-alias only if we have an existing Team ID to choose
    # from.
    self.chosen_team_id.to_i > 0
  end

  # +true+ if one of the suggested action for this result
  # is the creation of a brand new team row.
  def can_insert_team
    # We can create a new team only if NO pre-existing teams have already been
    # selected or found.
    self.chosen_team_id.nil?
  end

  # +true+ if one of the suggested action for this result
  # is the creation of a new team affiliation row.
  def can_insert_affiliation
    # We can create a new affiliation only if there are no best-matches among
    # the existing ones.
    self.best_match_name.nil?
  end
  #-- -------------------------------------------------------------------------
  #++

  # Overwrites (rebuilds from scratch) the sql_text using the (already set) internal values of
  # its members. It doesn't save the instance, it just updates its sql_text member
  # according to the other current values.
  #
  # === Returns:
  # The updated (and current) values of sql_text.
  #
  def rebuild_sql_text()
    con = self.class.connection
    self.sql_text = "\r\n"
    if can_insert_team
# FIXME [Steve, 20170213] We should only create secondary entities during phases < 3!
#      self.sql_text << "INSERT INTO teams (name,editable_name,address,e_mail,contact_name,user_id,created_at,updated_at) VALUES\r\n" <<
#                       "    (#{ con.quote( self.searched_team_name ) }," <<
#                       "#{ con.quote( self.searched_team_name )},'','','',1,CURDATE(),CURDATE());\r\n"
      self.sql_text << "INSERT INTO data_import_teams (data_import_session_id, import_text, name, user_id, created_at, updated_at) VALUES\r\n" <<
                       "    (#{ data_import_session_id }, #{ con.quote( self.searched_team_name ) }, " <<
                       "#{ con.quote( self.searched_team_name )}, 1, CURDATE(), CURDATE());\r\n"
    end

    if can_insert_alias
      self.sql_text << "INSERT INTO data_import_team_aliases (name,team_id,created_at,updated_at) VALUES\r\n" <<
                       "    (#{ con.quote( self.searched_team_name ) },#{ self.chosen_team_id.to_i },CURDATE(),CURDATE());\r\n"
    end

# FIXME [Steve, 20170213] Affiliations should be created only during phase 3!
    if can_insert_affiliation
      self.sql_text << "-- team_affiliations CREATION SKIPPED DURING TEAM ANALYSIS! The affiliation should be created during phase 3!\r\n"
#      self.sql_text << "INSERT INTO team_affiliations (season_id,team_id,name,number,must_calculate_goggle_cup,user_id,created_at,updated_at) VALUES\r\n"
#      if can_insert_alias
#        self.sql_text << "    (#{self.desired_season_id},#{self.chosen_team_id.to_i}," <<
#                         "#{ con.quote( self.searched_team_name ) },'',0,1,CURDATE(),CURDATE());\r\n"
#      else
#        self.sql_text << "    (#{self.desired_season_id},(select t.id from teams t where " <<
#                         "t.name = #{ con.quote( self.searched_team_name ) })," <<
#                         "#{ con.quote( self.searched_team_name ) },'',0,1,CURDATE(),CURDATE());\r\n"
#      end
    end
    self.sql_text
  end


  # Convert the current instance to a readable string
  def to_s
    "[DataImportTeamAnalysisResult: data_import_session_id=#{data_import_session_id}, '#{searched_team_name}', season_id=#{desired_season_id} -" +
    " team match: '#{team_match_name}' (ID:#{chosen_team_id}) score: #{team_match_score}," +
    " best match: '#{best_match_name}' score: #{team_match_score}]"
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
