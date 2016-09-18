require 'factory_girl'


=begin

= ControllerMacros

  - author:   Steve A.

  Support module for RSpec for defining utility helpers for controller specs.

  Note that all the methods contained here are meant to be used at the instance
  level (that is, inside a spec example or a block, like a "before-each" hook body,
  not a "before-all").

  This implies also that this module should be included in RSpec configuration
  using #include (and not #extend).

=end
module ControllerMacros
  include Rails.application.routes.url_helpers

  # Default #url_for options override.
  def default_url_options( options = { locale: 'en', only_path: true } )
    @options = options
  end

  # Composes and returns the #url_for the specified controller
  # (using only its table name) and action.
  #
  def url_to_action_for( table_name, action_name = 'index' )
    url_for(
      controller: table_name,
      action:     action_name,
      locale:     default_url_options[:locale],
      only_path:  default_url_options[:only_path]
    )
  end
  #-- -------------------------------------------------------------------------
  #++


  # Logs-in a User instance created with FactoryGirl
  # before each test of the group when invoked.
  # Default RSpec version with Devise-only authentication.
  #
  # Assigns an @user User instance with the currently logged-in user.
  #
  def login_user( chosen_user = nil )
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = chosen_user || FactoryGirl.create(:user)
    sign_in @user
  end
  #-- -------------------------------------------------------------------------
  #++


  # User Login checker for GET actions only.
  #
  # GETs the specified <tt>action_sym</tt> (/:id) and
  # expects the response to redirect to the sign-in session page for a User.
  #
  def get_action_and_check_it_redirects_to_login_for( action_sym, login_absolute_path = "/users/sign_in", id = nil )
    get( action_sym, params: { id: id } )
    expect(response).to be_a_redirect # (= 302, must redirect to the login page)
    # [Steve A.]
    # NOTE that the path below assumes that the Core Engine including
    # the Devise routes is mounted to "/". (Otherwise is should be changed
    # to something like "/mounting_path/users/sign_in").
    # Keep in mind also that:
    #   new_user_session_path( locale='XX' ) => '/users/sign_in?locale=XX'
    expect(response).to redirect_to( login_absolute_path )
  end
  #-- -------------------------------------------------------------------------
  #++
end