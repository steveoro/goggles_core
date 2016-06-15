#
# == TrainingAccessibility
#
# Strategy Pattern implementation for TrainingSharable access and action-enable
# policy.
#
# @author   Steve A.
# @version  4.00.450
#
class TrainingAccessibility

  # == Params:
  # An instance of Training, the current User instance and the flag indicating if the Admin is logged-in or not.
  def initialize( current_user, training, is_admin_logged_in )
    @current_user = current_user
    @training = training
    @is_admin_logged_in = is_admin_logged_in
  end
  #-- --------------------------------------------------------------------------
  #++

  # Checks if the current_user owns the specified training.
  # Returns +true+ when successful.
  #
  def is_owned()
    !!(
      @training && 
      @training.id &&
      ( 
        @is_admin_logged_in || ( @current_user && (@training.user_id == @current_user.id) ) 
      )
    )
  end

  # Checks if the current_user can access (R/O) the specified training
  # Returns +true+ when successful.
  #
  def is_visible()
    !!( @training && @training.id && ( @is_admin_logged_in || @current_user ) )
  end
  #-- --------------------------------------------------------------------------
  #++
end
