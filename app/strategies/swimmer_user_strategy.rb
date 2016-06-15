#
# == SwimmerUserStrategy
#
# Strategy Pattern implementation for Swimmer-User relations and action-enable
# policy.
#
# @author   Steve A.
# @version  4.00.285
#
class SwimmerUserStrategy

  def initialize( swimmer )
    @swimmer = swimmer
  end
  #-- --------------------------------------------------------------------------
  #++

  # Returns true if this swimmer instance can support the "social/confirm"
  # action links or buttons. False otherwise.
  #
  def is_confirmable_by( another_user )
    !!(
      is_associated_to_somebody_else_than( another_user ) &&
      another_user.find_any_confirmation_given_to( @swimmer.associated_user ).nil?
    )
  end

  # Returns true if this swimmer instance can support the "social/unconfirm"
  # action links or buttons. False otherwise.
  #
  def is_unconfirmable_by( another_user )
    !!(
      is_associated_to_somebody_else_than( another_user ) &&
      !another_user.find_any_confirmation_given_to( @swimmer.associated_user ).nil?
    )
  end
  #-- --------------------------------------------------------------------------
  #++


  # Returns true if this swimmer instance can support the "social/invite friend"
  # action links or buttons. False otherwise.
  #
  # @see #is_pending_for()
  # @see #is_approvable_by()
  #
  def is_invitable_by( another_user )
    !!(
      is_associated_to_somebody_else_than( another_user ) &&
      @swimmer.associated_user.find_any_friendship_with( another_user ).nil?
    )
  end


  # Returns true if this swimmer instance cannot "invite socially" another friend
  # because the invite has already been sent and it is pending for acceptance.
  # False otherwise.
  #
  # "Pending" friendships are the only "approvable" ones in the sense that they can be
  # both active and passive subjects. But from an "active" (meaning "user-clickable")
  # point of view, an "approvable" friendship is the only one having as friend the
  # same user browsing the page. A "Pending" friendship matches the friendable instead.
  #
  # Simply put:
  # - A pending friendship, waiting for approval from the friend:
  #   => it is "pending" for the friendable,
  #   => it is "approvable" by the friend.
  #
  # @see #is_approvable_by()
  #
  def is_pending_for( another_user )
    return false unless is_associated_to_somebody_else_than( another_user )
    existing_friendship = @swimmer.associated_user.find_any_friendship_with( another_user )
    !!(
      existing_friendship &&
      existing_friendship.pending? &&
      (existing_friendship.friendable_id == another_user.id) # Another user is the one *sending* the invite
    )
  end


  # Returns true if this swimmer instance can "approve socially" another friend request
  # because the invite has already been sent and it is pending for acceptance.
  # False otherwise.
  #
  # "Pending" friendships are the only "approvable" ones in the sense that they can be
  # both active and passive subjects. But from an "active" (meaning "user-clickable")
  # point of view, an "approvable" friendship is the only one having as friend the
  # same user browsing the page. A "Pending" friendship matches the friendable instead.
  #
  # Simply put:
  # - A pending friendship, waiting for approval from the friend:
  #   => it is "pending" for the friendable,
  #   => it is "approvable" by the friend.
  #
  # @see #is_pending_for()
  #
  def is_approvable_by( another_user )
    return false unless is_associated_to_somebody_else_than( another_user )
    existing_friendship = @swimmer.associated_user.find_any_friendship_with( another_user )
    !!(
      existing_friendship &&
      existing_friendship.pending? &&
      (existing_friendship.friend_id == another_user.id) # Another user is the one *receiving* the invite
    )
  end
  #-- --------------------------------------------------------------------------
  #++


  # Returns true if this swimmer instance can support the "social/block friendship"
  # action links or buttons. False otherwise.
  #
  def is_blockable_by( another_user )
    return false unless is_associated_to_somebody_else_than( another_user )
    existing_friendship = @swimmer.associated_user.find_any_friendship_with( another_user )
    !!(
      existing_friendship &&
      existing_friendship.can_block?( another_user )
    )
  end


  # Returns true if this swimmer instance can support the "social/unblock friendship"
  # action links or buttons. False otherwise.
  #
  def is_unblockable_by( another_user )
    return false unless is_associated_to_somebody_else_than( another_user )
    existing_friendship = @swimmer.associated_user.find_any_friendship_with( another_user )
    !!(
      existing_friendship &&
      existing_friendship.can_unblock?( another_user )
    )
  end


  # Returns true if this swimmer instance can support the "social/edit (or remove) friendship"
  # action links or buttons. False otherwise.
  #
  def is_editable_by( another_user )
    !!(
      is_associated_to_somebody_else_than( another_user ) &&
      !@swimmer.associated_user.find_any_friendship_with( another_user ).nil?
    )
  end
  #-- --------------------------------------------------------------------------
  #++


  # Check if this Swimmer object is correctly associated to a user and if it's a
  # different user from the one specified, plus they both have different swimmers
  # associated with their accounts.
  #
  # Returns true if the associated user is different from +another_user+.
  # False otherwise.
  #
  def is_associated_to_somebody_else_than( another_user )
    !!(
      another_user &&                               # User exists...
      another_user.swimmer &&                       # It has a swimmer associated...
      @swimmer &&                                   # Ditto for this strategy's object...
      @swimmer.associated_user &&                   # ...And their are different gogglers:
      ( @swimmer.associated_user_id != another_user.id ) &&
      ( @swimmer.id != another_user.swimmer_id )    # (additional and redundant integrity check)
    )
  end
  #-- --------------------------------------------------------------------------
  #++
end
