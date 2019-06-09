# frozen_string_literal: true

class SwimmerSeasonScore < ApplicationRecord

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  belongs_to :badge
  belongs_to :event_type
  belongs_to :meeting_individual_result

  validates_associated :badge
  validates_associated :meeting_individual_result

  has_one  :swimmer,          through: :badge
  has_one  :team,             through: :badge
  has_one  :season,           through: :badge
  has_one  :category_type,    through: :badge
  has_one  :gender_type,      through: :swimmer

  validates :score, presence: true
  validates :score, numericality: true

  delegate :code,       to: :event_type, prefix: true
  delegate :code,       to: :category_type, prefix: true
  delegate :code,       to: :gender_type, prefix: true

  scope :sort_by_score, ->(dir = 'DESC') { order("score #{dir}") }
  # ----------------------------------------------------------------------------

  # Retrieves the associated Swimmer full name
  def get_swimmer_name
    swimmer ? swimmer.get_full_name : '?'
  end

  # Retrieves the associated Team full name
  def get_team_name
    team ? team.get_full_name : '?'
  end
  # ----------------------------------------------------------------------------

end
