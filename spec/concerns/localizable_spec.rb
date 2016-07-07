require 'rails_helper'

# Surely this spec is actually not really required anymore, since there are already
# plenty of Modules that have their own specs testing the inclusion and the inner workings
# of this concern.
# This is left here only as example of how the concern has been 'TDD'eveloped before it
# was even ready to be used in Production.


# Dummy class holder for the fields used by the module
class DummyLocalizableIncludee < Achievement
  include Localizable
end

# Works also this way: (Note that the inclusion is done *after* the definition
# of the attribute & method, since there's no ActiveRecord base class here)
#
# class DummyLocalizableIncludee
#   attr_accessor :code
#   def self.table_name;  'any_subentity_name'; end
#   include Localizable
# end
# -----------------------------------------------------------------------------


describe DummyLocalizableIncludee do
  it_behaves_like "Localizable"
end
