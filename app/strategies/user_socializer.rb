#
# == UserSocializer
#
# Strategy/B-L incapsulator for User-social interactions with news-feed generation.
#
# @author   Steve A.
# @version  4.00.625
#
class UserSocializer

  def initialize( user )
    raise ArgumentError.new("'user' parameter must be an instance of User") unless user.instance_of?( User )
    @user = user
  end
  #-- --------------------------------------------------------------------------
  #++

  # Confirms another user as being associated to its current swimmer.
  # 'Another user' must be already self-associated with a swimmer. This operation
  # simply adds a confirmator to the self-assesment.
  # If the operation succeeds, the method returns true; false otherwise.
  #
  # Works similarly to UserSwimmerConfirmator#confirm_for() but in addition it updates the
  # news feed for both the recipient (another_user, not-necessarily a friend yet) and
  # the sender (the current @user for this instance).
  #
  # Returns the confirmation row on success, +nil+ otherwise.
  #
  def confirm_with_notify( another_user )
    return nil unless another_user.instance_of?(User) && @user.has_associated_swimmer? && another_user.has_associated_swimmer?
    result = UserSwimmerConfirmation.confirm_for( another_user, another_user.swimmer, @user )
    if result
      NewsFeed.create_social_feed(
        another_user.id,
        @user.id,
        I18n.t('newsfeed.confirm_title'),
        I18n.t('newsfeed.confirm_body').gsub("{SWIMMER_NAME}", @user.get_full_name)
      )
      NewsFeed.create_social_feed(
        @user.id,
        another_user.id,
        I18n.t('newsfeed.done_confirm_title'),
        I18n.t('newsfeed.done_confirm_body')
          .gsub("{BUDDY_NAME}", another_user.name)
          .gsub("{SWIMMER_NAME}", another_user.swimmer.get_full_name)
      )
# FIXME This will make all unique another_user's team-buddies as friends:
      TeamBuddyLinker.new( another_user ).socialize_with_team_mates
      # TODO Create also achievement accordingly
    end
    result
  end

  # De-Confirms (or un-confirms) another user as being associated to its current swimmer.
  # 'Another user' must be already self-associated with a swimmer. This operation
  # simply adds a confirmator to the self-assesment.
  # If the operation succeeds, the method returns true; false otherwise.
  #
  # Works similarly to UserSwimmerConfirmator#unconfirm_for() but in addition it updates the
  # news feed for just the recipient (another_user, not-necessarily a friend yet).
  #
  # Returns the confirmation row on success, +nil+ otherwise.
  #
  def unconfirm_with_notify( another_user )
    return nil unless another_user.instance_of?(User) && @user.has_associated_swimmer? && another_user.has_associated_swimmer?
    result = UserSwimmerConfirmation.unconfirm_for( another_user, another_user.swimmer, @user )
    if result
      NewsFeed.create_social_feed(
        another_user.id,
        @user.id,
        I18n.t('newsfeed.unconfirm_title'),
        I18n.t('newsfeed.unconfirm_body').gsub("{SWIMMER_NAME}", another_user.swimmer.get_full_name)
      )
      # TODO Block friendships also?
      # TODO Create also achievement accordingly
    end
    result
  end
  #-- --------------------------------------------------------------------------
  #++

  # Suggest a user to become a friend. If the operation succeeds, the method returns true, else false.
  #
  # Same as User#invite() but updates also the news feed for the recipient (the
  # invited friend) and sends him/her a notification e-mail.
  #
  # The "requestee" friendable can also set the requested sharing attributes which
  # will then either be confirmed (set to true) or denied (set to false) during the approval process.
  #
  def invite_with_notify( swimming_buddy, shares_passages = false, shares_trainings = false, shares_calendars = false )
    if @user.invite( swimming_buddy, shares_passages, shares_trainings, shares_calendars )
      news_feed = NewsFeed.create_social_feed(
        swimming_buddy.id,
        @user.id,
        I18n.t('newsfeed.invite_title'),
        I18n.t('newsfeed.invite_body').gsub("{SWIMMER_NAME}", @user.get_full_name),
        false # (This is no 'temp/achievement' kind of feed, so we'll generate a newsletter mail until it is read)
      )
      # Generate a nofify mail without delay:
      NewsletterMailer.community_mail( swimming_buddy, news_feed ).deliver
    end
  end

  # Approves a friendship invitation. If the operation succeeds, the method returns true, else false.
  #
  # Same as User#approve() but updates also the news feed for both the recipient (the
  # approved friend) and the sender (the user accepting the request).
  #
  # The friend approving a friendship request can only set sharing attributes
  # to true if the "requestee" friendable asked for it, setting them previously
  # with an invite request.
  # Otherwise, set the sharing attributes using their dedicated setter methods.
  # (#set_share_passages_with, #set_share_trainings_with, #set_share_calendar_with)
  #
  def approve_with_notify( swimming_buddy, shares_passages = false, shares_trainings = false, shares_calendars = false )
    if @user.approve( swimming_buddy, shares_passages, shares_trainings, shares_calendars )
      NewsFeed.create_social_approve_feed( @user, swimming_buddy )
      # TODO Create also achievement row accordingly?
    end
  end

  # Same as User#remove_friendship() but updates also the news feed for the sender (the
  # user casting the deletion on the friendship, to get something like
  # "you are no longer a swimming buddy of ...").
  #
  def remove_with_notify( swimming_buddy )
    if @user.remove_friendship( swimming_buddy )
      NewsFeed.create_social_feed(
        @user.id,
        swimming_buddy.id,
        I18n.t('newsfeed.remove_title'),
        I18n.t('newsfeed.remove_body').gsub("{SWIMMER_NAME}", swimming_buddy.get_full_name)
      )
      # TODO Create also achievement row accordingly?
    end
  end
  #-- --------------------------------------------------------------------------
  #++
end
