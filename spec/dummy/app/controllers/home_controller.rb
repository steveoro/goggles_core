class HomeController < ApplicationController
  # Devise HTTP log-in strategy:
  before_action :authenticate_user!,  only: [:restricted_info]

  # Basic index action to test inclusion of the Core engine, open to all users
  #
  def index
  end
  #-- -------------------------------------------------------------------------
  #++

  # Action restricted to registered users.
  # Used to test inclusion of the Core engine.
  #
  def restricted_info
    @for_user_eyes_only = "I guess you are a logged-id User!"
  end
  #-- -------------------------------------------------------------------------
  #++

end
