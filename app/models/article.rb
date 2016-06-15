=begin

= Article model

  - version:  4.00.483
  - author:   Steve A.

=end
class Article < ActiveRecord::Base
  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!

  validates_presence_of :title, length: { within: 1..80 }, allow_nil: false
  validates_presence_of :body

  scope :sort_by_user,  ->(dir) { joins(:user).order("users.name #{dir.to_s}, articles.created_at #{dir.to_s}") }
  scope :permalinks,    ->      { where( is_sticky: true ) }


  delegate :name, to: :user, prefix: true
  #-- -------------------------------------------------------------------------
  #++

  # Returns a short description or title for the current instance
  def get_full_name
    self.title
  end
  #-- -------------------------------------------------------------------------
  #++
end
