require 'active_support'

=begin

= TrainingSharable

  - version:  4.00.329.20140701
  - author:   Steve A.

  Concern that adds special visibility scopes to any model concerning the sharing
  of trainings between Users.

  The includee model will +belong_to+ :user by including this concern.

=end
module TrainingSharable
  extend ActiveSupport::Concern

  included do
    belongs_to :user
  end

  # Returns true if the current instance is visible to the specified <tt>another_user</tt>.
  #
  def visible_to_user( another_user )
    allowed_user_ids = user.friends_sharing_trainings.select(:id).collect{ |e| e.id } << user_id
    allowed_user_ids.include?( another_user.id )
  end
  #-- -------------------------------------------------------------------------
  #++

  module ClassMethods
    # This scope will select only the rows visible to a specified <tt>any_user</tt>.
    def visible_to_user( any_user )
      allowed_user_ids = any_user.friends_sharing_trainings.select(:id) << any_user.id
      where( ["user_id IN (?)", allowed_user_ids] )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
