# frozen_string_literal: true

#
# = TeamManager model
#
#  Stores the associations between specific *team* affiliations and users deemed
#  to act as their managers.
#
class TeamManager < ApplicationRecord

  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
  #  validates_associated :user                       # (Do not enable this for User)

  belongs_to :team_affiliation
  validates_associated :team_affiliation

  has_one  :team, through: :team_affiliation

  delegate :name, to: :user, prefix: true
  #-- -------------------------------------------------------------------------
  #++

end
