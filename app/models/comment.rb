=begin

= Comment model

  - version:  6.069
  - author:   Steve A.

=end
class Comment < ApplicationRecord
  # XXX [Steve, 20170130] We don't care anymore (so much) about these updates: commented out
#  after_create    UserContentLogger.new('comments')
#  after_update    UserContentLogger.new('comments')
#  before_destroy  UserContentLogger.new('comments')

  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!
  belongs_to :swimming_pool_review
  belongs_to :comment

  validates_presence_of :entry_text

  delegate :name, to: :user, prefix: true

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :user_id, :swimming_pool_review_id, :comment_id
#                  :entry_text

  scope :sort_by_user,  ->(dir) { order("users.name #{dir.to_s}, comments.created_at #{dir.to_s}") }
  #-- -------------------------------------------------------------------------
  #++
end
