# encoding: utf-8


=begin

= UserSwimmerConfirmation model

  - version:  6.069
  - author:   Steve A.

  Holds confirmations received by a user about its association with a
  swimmer_id.

=end
class UserSwimmerConfirmation < ApplicationRecord
  # XXX [Steve, 20170130] We don't care anymore (so much) about these updates: commented out
#  after_create    UserContentLogger.new('user_swimmer_confirmations')
#  after_update    UserContentLogger.new('user_swimmer_confirmations')
#  before_destroy  UserContentLogger.new('user_swimmer_confirmations')

  # [Steve, 20140930] We don't need to keep around NULL'ed UserSwimmerConfirmations if a user is deleted:
  belongs_to :user, dependent: :destroy
  belongs_to :swimmer
  validates_associated :swimmer

  belongs_to :confirmator,
    class_name: User,
    foreign_key: "confirmator_id"

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :user_id, :swimmer_id, :confirmator_id

  scope :find_for_user,         ->(user) { where( user_id: user.id ) }
  scope :find_for_confirmator,  ->(confirmator) { where( confirmator_id: confirmator.id ) }
  scope :find_any_between,      ->(user, confirmator) { where( confirmator_id: confirmator.id, user_id: user.id ) }
  #-- -------------------------------------------------------------------------
  #++


  # Confirms the association for a user to a swimmer, given another
  # user that acts as a "confirmator".
  #
  # The parameters can either be model instances or simple IDs.
  # Returns the confirmation row on success, +nil+ otherwise.
  #
  def self.confirm_for( user, swimmer, confirmator )
    user_id, swimmer_id, confirmator_id = self.parse_parameters( user, swimmer, confirmator )
    return nil unless self.validate_parameters( user_id, swimmer_id, confirmator_id )
    begin
      UserSwimmerConfirmation.create!(
        user_id: user_id,
        swimmer_id: swimmer_id,
        confirmator_id: confirmator_id
      )
    rescue
      nil
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Removes the single confirmation row for the association between a user and a swimmer,
  # given another user that acts as a "confirmator" (in this case, the "un-confirmator").
  #
  # Only coherent tuples can be deleted. That is, only the rows having the same ID values
  # as the specified parameters will be removed.
  #
  # The parameters can either be model instances or simple IDs (Fixnum).
  # Returns +true+ on success, +false+ otherwise.
  #
  def self.unconfirm_for( user, swimmer, confirmator )
    user_id, swimmer_id, confirmator_id = self.parse_parameters( user, swimmer, confirmator )
    return false unless self.validate_parameters( user_id, swimmer_id, confirmator_id )

    unconfirmable_row = UserSwimmerConfirmation.where(
      user_id: user_id,
      swimmer_id: swimmer_id,
      confirmator_id: confirmator_id
    ).first

    if unconfirmable_row
      begin
        unconfirmable_row.destroy()
      rescue
        false
      end
    else
      false
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  private


  # Parses the parameters for self.confirm_for() or self.unconfirm_for().
  # Returns the array of parameters.
  def self.parse_parameters( user, swimmer, confirmator )
    user_id        = user.instance_of?( User ) ? user.id : user
    swimmer_id     = swimmer.instance_of?( Swimmer ) ? swimmer.id : swimmer
    confirmator_id = confirmator.instance_of?( User ) ? confirmator.id : confirmator
    [ user_id, swimmer_id, confirmator_id ]
  end


  # Returns true if all the parameters are valid for a self.confirm_for/() or
  # self.unconfirm_for() call.
  def self.validate_parameters( user_id, swimmer_id, confirmator_id )
    (
      user_id.kind_of?( Fixnum )        && user_id.to_i > 0 &&
      swimmer_id.kind_of?( Fixnum )     && swimmer_id.to_i > 0 &&
      confirmator_id.kind_of?( Fixnum ) && confirmator_id.to_i > 0
    )
  end
  #-- -------------------------------------------------------------------------
  #++
end
