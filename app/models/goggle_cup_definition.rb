
class GoggleCupDefinition < ActiveRecord::Base

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  belongs_to :goggle_cup
  belongs_to :season
  validates_associated :goggle_cup
  validates_associated :season
  
  has_one :team,  through: :goggle_cup

  scope :sort_by_begin_date,  ->(dir) { includes(:season).order("seasons.begin_date #{dir.to_s}") }
  scope :sort_by_end_date,    ->(dir) { includes(:season).order("seasons.end_date #{dir.to_s}") }


  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------

  # Retrieves the user name associated with this instance
  def user_name
    self.user ? self.user.name : ''
  end
  # ----------------------------------------------------------------------------

end
