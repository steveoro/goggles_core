# encoding: utf-8


=begin

= SwimmingPoolReview model

  - version:  4.00.523
  - author:   Steve A.

=end
class SwimmingPoolReview < ApplicationRecord
  after_create    UserContentLogger.new('swimming_pool_reviews')
  after_update    UserContentLogger.new('swimming_pool_reviews')
  before_destroy  UserContentLogger.new('swimming_pool_reviews')

  acts_as_votable

  belongs_to :user
  # [Steve, 20120212] Validating on User fails always because of validation requirements inside User (password & salt)
#  validates_associated :user                       # (Do not enable this for User)

  belongs_to :swimming_pool
  validates_associated :swimming_pool

  validates_presence_of :title
  validates_length_of   :title, within: 1..100, allow_nil: false

  validates_presence_of :entry_text


  delegate :name, to: :user, prefix: true, allow_nil: true

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :title, :entry_text, :user_id, :swimming_pool_id

  scope :sort_swimming_pool_by_user,          ->(dir) { order("users.name #{dir.to_s}, swimming_pools.name #{dir.to_s}") }
  scope :sort_swimming_pool_by_swimming_pool, ->(dir) { order("swimming_pools.name #{dir.to_s}") }
  #-- -------------------------------------------------------------------------
  #++

  # Computes a shorter description for the name associated with this data
  def get_full_name
    title
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "[#{user_name}] #{title}"
  end

  # Safe getter for swimming pool name
  def swimming_pool_name( method_sym = :get_verbose_name )
    self.swimming_pool ? self.swimming_pool.send(method_sym.to_sym) : '?'
  end
  #-- -------------------------------------------------------------------------
  #++
end
