=begin

= NewsFeed model

  - version:  4.00.625
  - author:   Steve A.

=end
class NewsFeed < ActiveRecord::Base
  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!
  belongs_to :friend, class_name: "User", foreign_key: "friend_id"

  validates_presence_of :user_id
  validates_presence_of :title, length: { within: 1..150 }, allow_nil: false

  scope :unread,                  -> { where( is_read: false ) }
  scope :friend_activities,       -> { where( is_friend_activity: true ) }
  scope :only_achievements,       -> { where( is_achievement: true ) }
  scope :newsletter_activities,   -> { unread.where( is_achievement: false ) }

  scope :sort_by_user,            ->(dir) { order("users.name #{dir.to_s}, news_feeds.created_at #{dir.to_s}") }

  attr_accessible :body, :user_id, :friend_id, :is_achievement, :is_friend_activity, :is_read, :title

  after_initialize do
    set_default_bool_value( :is_read )
    set_default_bool_value( :is_friend_activity )
    set_default_bool_value( :is_achievement )
  end


  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------


  # Computes a shorter description for the name associated with this data
  def get_full_name
    self.title
  end

  # Retrieves the user name associated with this article
  def user_name
    name = self.user.nil? ? '' : self.user.name
  end

  # Retrieves the user name associated with this article
  def friend_name
    name = self.friend.nil? ? '' : self.friend.name
  end
  # ----------------------------------------------------------------------------


  # Creates a the social/approve News-Feed entry for both the user and the friend.
  # This will also flag the newly created feed as belonging to the kind 'temp/achievement',
  # which is skipped by the weekly newsletter of unread feeds.
  #
  def self.create_social_approve_feed( user, friend )
    self.create_social_feed(
      user.id,
      friend.id,
      I18n.t('newsfeed.approve_title'),
      I18n.t('newsfeed.approve_body').gsub("{SWIMMER_NAME}", friend.get_full_name)
    )
    self.create_social_feed(
      friend.id,
      user.id,
      I18n.t('newsfeed.approve_title'),
      I18n.t('newsfeed.approve_body').gsub("{SWIMMER_NAME}", user.get_full_name)
    )
  end

  # Creates a the social/remove News-Feed entry for only the user.
  # This will also flag the newly created feed as belonging to the kind 'temp/achievement',
  # which is skipped by the weekly newsletter of unread feeds.
  #
  def self.create_social_remove_feed( user, friend )
    self.create_social_feed(
      user.id,
      friend.id,
      I18n.t('newsfeed.remove_title'),
      I18n.t('newsfeed.remove_body').gsub("{SWIMMER_NAME}", friend.get_full_name)
    )
  end
  # ----------------------------------------------------------------------------


  # Utility method for creating a new social feed row.
  #
  # When +is_achievement+ is +true+ (the default) this newsfeed will be skipped
  # from the weekly newsletter of all unread feeds.
  #
  def self.create_social_feed( user_id, friend_id, title, body, is_achievement = true )
    NewsFeed.create!(
      user_id: user_id,
      friend_id: friend_id,
      is_friend_activity: true,
      is_achievement: is_achievement,
      title: title,
      body: body
    )
  end
  # ----------------------------------------------------------------------------


  # Creates a the achievement/confirm News-Feed entry for only the user.
  # The bias_value is the achievement unlock bias.
  #
  # Keep in mind that news feeds flagged as belonging to the kind 'is_achievement'
  # won't be notified by the weekly newsletter of the unread feeds.
  #
  def self.create_achievement_approve_feed( user, friend, bias_value )
    self.create_achievement_feed(
      user.id,
      friend.id,
      I18n.t('achievement.generic_title'),
      I18n.t('achievement.approve_body').gsub("{N}", bias_value.to_s)
    )
  end

  # Creates a the achievement/confirm News-Feed entry for only the user.
  # The bias_value is the achievement unlock bias.
  #
  # Keep in mind that news feeds flagged as belonging to the kind 'is_achievement'
  # won't be notified by the weekly newsletter of the unread feeds.
  #
  def self.create_achievement_confirm_feed( user, friend, bias_value )
    self.create_achievement_feed(
      user.id,
      friend.id,
      I18n.t('achievement.generic_title'),
      I18n.t('achievement.confirm_body').gsub("{N}", bias_value.to_s)
    )
  end
  # ----------------------------------------------------------------------------

  # Utility method for creating a new achievement feed row.
  #
  # Keep in mind that news feeds flagged as belonging to the kind 'is_achievement'
  # won't be notified by the weekly newsletter of the unread feeds.
  #
  def self.create_achievement_feed( user_id, friend_id, title, body )
    NewsFeed.create!(
      user_id: user_id,
      friend_id: friend_id,
      is_achievement: true,
      title: title,
      body: body
    )
  end
  # ----------------------------------------------------------------------------


  private


  def set_default_bool_value( field_name_sym, default_value = false )
    if send( field_name_sym.to_sym ).blank?
      send( "#{field_name_sym}=".to_sym, default_value )
    end
  end
end
