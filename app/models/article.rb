# frozen_string_literal: true

#
# = Article model
#
#   - version:  4.00.483
#   - author:   Steve A.
#
class Article < ApplicationRecord

  belongs_to :user # [Steve, 20120212] Do not validate associated user!

  validates :title, presence: { length: { within: 1..80 }, allow_nil: false }
  validates :body, presence: true

  scope :sort_by_user,  ->(dir) { joins(:user).order("users.name #{dir}, articles.created_at #{dir}") }
  scope :permalinks,    ->      { where(is_sticky: true) }

  delegate :name, to: :user, prefix: true
  #-- -------------------------------------------------------------------------
  #++

  # Returns a short description or title for the current instance
  def get_full_name
    title
  end
  #-- -------------------------------------------------------------------------
  #++

end
