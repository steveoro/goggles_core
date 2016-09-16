# encoding: utf-8
require 'drop_down_listable'


=begin

= Team model

  Encloses data for a specific and unique Team, which can have several TeamAffiliation(s),
  one for each academic/sport year.

=end
class Team < ApplicationRecord
  include DropDownListable

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!
  belongs_to :city                                  # City can be null especially in Teams added by data-import

  has_many :badges
  has_many :swimmers, through: :badges # May used with uniq

  has_many :meeting_individual_results
  has_many :meetings, through: :meeting_individual_results
  has_many :meeting_relay_results
  has_many :meeting_team_scores
  has_many :team_affiliations
  has_many :seasons,        through: :team_affiliations
  has_many :season_types,   through: :team_affiliations
  has_many :team_managers,  through: :team_affiliations
  has_many :goggle_cups
  has_many :computed_season_ranking
  has_many :team_passage_templates

  validates_presence_of :name
  validates_length_of :name, within: 1..60, allow_nil: false

  validates_presence_of :editable_name
  validates_length_of :editable_name, within: 1..60, allow_nil: false

  validates_length_of :address,       maximum: 100
  validates_length_of :phone_mobile,  maximum:  40
  validates_length_of :phone_number,  maximum:  40
  validates_length_of :fax_number,    maximum:  40
  validates_length_of :e_mail,        maximum: 100
  validates_length_of :contact_name,  maximum: 100
  validates_length_of :home_page_url, maximum: 150

  scope :sort_team_by_user, ->(dir) { order("users.name #{dir.to_s}, teams.name #{dir.to_s}") }
  scope :sort_team_by_city, ->(dir) { order("cities.name #{dir.to_s}, teams.name #{dir.to_s}") }
  scope :sort_by_name,      ->(dir) { order("teams.name #{dir.to_s}") }

  scope :has_results,       -> { where("EXISTS(SELECT 1 from meeting_individual_results where not is_disqualified and team_id = teams.id)") }
  scope :has_many_results,  ->(how_many=20) { where(["(SELECT count(id) from meeting_individual_results where not is_disqualified and team_id = teams.id) > ?", how_many]) }

  delegate :name, to: :user, prefix: true

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :name, :name_variations, :user_id,
#                  :editable_name, :address, :zip, :phone_mobile, :phone_number,
#                  :fax_number, :e_mail, :contact_name, :home_page_url, :notes,
#                  :city_id
  #-- -------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    editable_name
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{editable_name}#{city ? ' - ' + city.get_full_name : ''}"
  end

  # Same as get_full_name but adds also the ID at the end.
  def get_full_name_with_id
    "#{editable_name} (#{id})"
  end
  #-- -------------------------------------------------------------------------
  #++


  # Check if team has a Goggle cup not closed (ended) at a certain date
  #
  # params
  # evaluation_date: the date the goggle cup should be current at (default today)
  #
  def has_goggle_cup_at?( evaluation_date = Date.today )
    goggle_cups.sort_goggle_cup_by_year('DESC').each do |goggle_cup|
      return true if goggle_cup.is_current_at?( evaluation_date )
    end
    false
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the current goggle cup if present
  #
  # params
  # evaluation_date: the date the goggle cup should be current at (default today)
  #
  def get_current_goggle_cup_at( evaluation_date = Date.today )
    goggle_cups.sort_goggle_cup_by_year('DESC').each do |goggle_cup|
      return goggle_cup if goggle_cup.is_current_at?( evaluation_date )
    end
    nil
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the current goggle cup name if present
  #
  # params
  # evaluation_date: the date the goggle cup should be current at (default today)
  #
  def get_current_goggle_cup_name_at( evaluation_date = Date.today )
    goggle_cups.sort_goggle_cup_by_year('DESC').each do |goggle_cup|
      return goggle_cup.get_full_name if goggle_cup.is_current_at?( evaluation_date )
    end
    'Goggle cup'
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the current affiliation for the given season
  #
  # params
  # season_type: the season type to search for (default MASFIN)
  #
  def get_current_affiliation( season_type = SeasonType.find_by_code('MASFIN') )
    team_affiliations.for_season_type( season_type ).for_year( Season.build_header_year_from_date ).first
  end
  #-- -------------------------------------------------------------------------
  #++

  # Label symbol corresponding to either a column name or a model method to be used
  # mainly in generating DropDown option lists.
  #
  # @overload inherited from DropDownListable
  #
  def self.get_label_symbol
    :get_full_name
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the array of unique swimmer IDs registered for a specified meeting_id
  #
  def self.get_swimmer_ids_for( team_id, meeting_id )
    team = Team.find_by_id( team_id )
    team ? team.meeting_individual_results.includes(:meeting).where(['meetings.id=?', meeting_id]).collect{|row| row.swimmer_id}.uniq : []
  end
  #-- -------------------------------------------------------------------------
  #++
end
