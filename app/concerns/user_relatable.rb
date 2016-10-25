require 'active_support'
=begin

= UserRelatable

  - version:  4.00.345.20140710
  - author:   Leega, Steve A.

Container module for interfacing common "user-related" info (name, ...)
and method functions.

Adds a <tt>belongs_to :user</tt> relationship to the includee.

=end
module UserRelatable
  extend ActiveSupport::Concern

  included do
    belongs_to :user                                # [Steve, 20120212] Do not validate associated user!
  end

  # Retrieves the user name associated with this instance
  def user_name
    user ? self.user.name : ''
  end

  alias :get_user_name :user_name
  #-- -------------------------------------------------------------------------
  #++

end
