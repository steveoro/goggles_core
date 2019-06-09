# frozen_string_literal: true

#
# = GoggleCup model
#
#   - version:  4.00.444
#   - author:   Leega
#
class GoggleCup < ApplicationRecord

  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
  #  validates_associated :user                       # (Do not enable this for User)

  belongs_to :team
  validates_associated :team

  has_many :goggle_cup_standards
  has_many :goggle_cup_definitions
  has_many :seasons,                    through: :goggle_cup_definitions
  has_many :meetings,                   through: :seasons
  has_many :season_types,               through: :seasons
  has_many :badges,                     through: :seasons # Do not use this!!!
  has_many :swimmers,                   through: :badges # Should used with uniq -> # Do not use this!!!
  has_many :meeting_individual_results, through: :badges

  validates :description, presence: true
  validates :description, length: { within: 1..60, allow_nil: false }

  validates :season_year, presence: true
  validates :season_year, length: { within: 2..4, allow_nil: false }
  validates :season_year, numericality: true
  validates :max_points, presence: true
  validates :max_points, length: { within: 1..9, allow_nil: false }
  validates :max_points, numericality: true
  validates :max_performance, presence: true
  validates :max_performance, length: { within: 1..2, allow_nil: false }
  validates :max_performance, numericality: true

  scope :sort_goggle_cup_by_user,  ->(dir)  { order("users.name #{dir}, teams.name #{dir}, goggle_cups.season_year #{dir}") }
  scope :sort_goggle_cup_by_team,  ->(dir)  { order("teams.name #{dir}, goggle_cups.season_year #{dir}") }
  scope :sort_goggle_cup_by_year,  ->(dir)  { order("goggle_cups.season_year #{dir}") }

  scope :is_closed_now,            -> { where('goggle_cups.end_date < curdate()') }
  scope :is_current,               -> { where('goggle_cups.end_date >= curdate()') }

  scope :for_team,                 ->(team) { where(team_id: team.id) }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    description.to_s
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{description} (#{season_year}) - #{team.name}"
  end

  # Retrieves the user name associated with this instance
  def user_name
    user ? user.name : ''
  end
  # ----------------------------------------------------------------------------

  # Get the begin date for the Goggle cup
  # The Goggle begin date is the earliest begin date of the seasons that compose the Goggle cup
  #
  def get_begin_date
    get_end_date.prev_year
  end

  # Get the end date for the Goggle cup
  # The Goggle end date is the latest end date of the seasons that compose the Goggle cup
  #
  def get_end_date
    end_date
  end

  # Check if a Goggle cup is closed (terminated) at a certain date
  # The Goggle cup is closed if the season that compose the Goggle cup are all closed
  # The latest end date should be past at least by one day
  #
  # Params
  # evaluation_date: the date for the evaluation, default today
  #
  def is_closed_at?(evaluation_date = Date.today)
    get_end_date < evaluation_date
  end

  # Check if a Goggle cup is the current (active) at a certain date
  # The Goggle cup is the current if the season that compose the Goggle cup are opened
  # that means that begin date is earlier that given date and
  # end date is is not past
  #
  # Params
  # evaluation_date: the date for the evaluation, default today
  #
  def is_current_at?(evaluation_date = Date.today)
    get_begin_date <= evaluation_date && get_end_date >= evaluation_date
  end

  # Check if a Goggle cup has at least one valid result
  #
  def has_results?
    meeting_individual_results.has_points(:goggle_cup_points).exists?
  end
  # ----------------------------------------------------------------------------

  # Check if a given team has a goggle cup for a certain season
  #
  def self.has_team_goggle_cup_for_season?(team_id, season_id)
    GoggleCup
      .joins(:goggle_cup_definitions)
      .includes(:goggle_cup_definitions)
      .where(
        ['team_id = ? AND goggle_cup_definitions.season_id = ?', team_id, season_id]
      ).exists?
  end
  # ----------------------------------------------------------------------------

  # Goggle cup rank calculaion
  # Calculate the goggle cup rank by collecting swimmers involved
  # and considering, for each, the estabilshed number of valid results
  # If any valid results is presente returns an empty array
  #
  def calculate_goggle_cup_rank
    # Prepares an hash to store goggle cup rank
    goggle_cup_rank = []

    # Check goggle cup has at least one valid result
    if has_results?
      # Collects swimmers involved
      # A swimmer is involved if has a badge for at a least a season of goggle cup definition
      # and is ranked if has at least a result for that badge(s)
      swimmers = team.badges
                     .joins(season: :goggle_cup_definitions)
                     .where(['goggle_cup_definitions.goggle_cup_id = ?', id])
                     .map(&:swimmer).uniq

      # Collects best results for each swimmer
      # The number of result to consider is set in the goggle cup header
      swimmers.each do |swimmer|
        points = swimmer.meeting_individual_results
                        .joins(season: :goggle_cup_definitions)
                        .where(['goggle_cup_definitions.goggle_cup_id = ?', id])
                        .has_points(:goggle_cup_points)
                        .sort_by_goggle_cup('DESC')
                        .limit(max_performance)
                        .collect(&:goggle_cup_points)
        next unless points.count > 0

        goggle_cup_rank << {
          swimmer: swimmer,
          total: points.sum,
          max: points.max,
          min: points.min,
          count: points.count,
          average: (points.sum / points.count).round(2)
        }
      end

      # Sorts the hash to create rank
      goggle_cup_rank.sort! { |hash_element_prev, hash_element_next| hash_element_next[:total] <=> hash_element_prev[:total] }
    end
    goggle_cup_rank
  end
  # ----------------------------------------------------------------------------

  # TODO
  # Store that values on DB
  # def age_for_negative_modifier
  #  20
  # end
  # def negative_modifier
  #  -10.0
  # end
  # def age_for_positive_modifier
  #  60
  # end
  # def positive_modifier
  #  5.0
  # end
  # def has_to_create_standards
  #  true
  # end
  # def has_to_update_standards
  #  false
  # end
  # ----------------------------------------------------------------------------

end
