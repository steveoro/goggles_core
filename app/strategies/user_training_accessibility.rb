#
# == UserTrainingAccessibility
#
# Strategy Pattern implementation for TrainingSharable access and action-enable
# policy.
#
# @author   Steve A.
# @version  5.00
#
class UserTrainingAccessibility

  # == Params:
  # An instance of UserTraining, the current User instance and the flag indicating if the Admin is logged-in or not.
  def initialize( current_user, user_training, is_admin_logged_in = false )
    @current_user = current_user
    @user_training = user_training
    @is_admin_logged_in = is_admin_logged_in
  end
  #-- --------------------------------------------------------------------------
  #++

  # Checks if the current_user owns the specified training.
  # Returns +true+ when successful.
  #
  def is_owned()
    !!(
      @user_training &&
      @user_training.id &&
      (
        @is_admin_logged_in ||
        ( @current_user && (@user_training.user_id == @current_user.id) )
      )
    )
  end

  # Checks if the current_user can access (R/O) the specified training.
  # Returns +true+ when successful.
  #
  def is_visible()
    !!(
      @user_training &&
      @user_training.id &&
      (
        @is_admin_logged_in ||
        ( @current_user && @user_training.visible_to_user(@current_user) )
      )
    )
  end
  #-- --------------------------------------------------------------------------
  #++
end
