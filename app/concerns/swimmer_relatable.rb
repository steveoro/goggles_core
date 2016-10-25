require 'active_support'
=begin

== SwimmerRelatable

- version:  4.00.219.20140413
- author:   Leega, Steve

Container module for interfacing common "swimming-related" info (name, year of birth)
and method functions.

=end
module SwimmerRelatable
  extend ActiveSupport::Concern

  included do
    belongs_to :swimmer
    validates_associated :swimmer
  end


  # Retrieves the associated Swimmer full name
  def get_swimmer_name
    swimmer ? swimmer.get_full_name() : '?'
  end

#  # Checks domain validity for the Swimmer full name
#  def is_swimmer_name_valid?
#    # TODO
#  end

  # Retrieves the associated Swimmer's year_of_birth
  def get_year_of_birth
    swimmer ? swimmer.year_of_birth : 0
  end
  #-----------------------------------------------------------------------------

  # Computes current swimmer age
  def get_swimmer_age
    swimmer ? Date.today.year - swimmer.year_of_birth : 0 # this will fail the tests if association in not defined
  end

#  # Checks domain validity for the Swimmer age
#  def is_swimmer_age_valid?
#    # TODO
#  end

  # Retrieves all the current category type codes for the swimmer association of this interface.
  # Returns an empty array when none is found or the association is missing.
  def get_swimmer_current_category_type_codes
    # TODO [Steve] Check out how this is defined in the Swimmer class
    # (it retrieves category type codes using only the swimmer year of birth):
    swimmer ? swimmer.get_current_category_type_codes() : []
  end

  # Retrieves the last-defined 'current' category type
  # Returns nil when none is found or the association is missing.
  def get_swimmer_current_category
    # TODO [Steve] It could also be possible to call swimmer.get_current_category_type_from_badges()
    # but it would also assume the badges association as valid.
    swimmer ? get_swimmer_current_category_type_codes.last : nil
  end

#  # Checks domain validity for the Swimmer current category
#  def is_swimmer_current_category_valid?
#    # TODO
#  end
end