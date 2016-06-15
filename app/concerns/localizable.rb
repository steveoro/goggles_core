require 'active_support'

=begin
  
= Localizable

  - version:  4.00.217.20140412
  - author:   Steve A.

  Concrete Interface for I18n helper methods.
  Assumes to be included into an ActiveRecord::Base sibling (it must respond to #table_name)
  and it must have a #code field.

=end
module Localizable
  extend ActiveSupport::Concern

  # This will raise an exception if the includee does not already have defined the required fields:
  def self.included( model )
    unless model.new.respond_to?(:code) && model.respond_to?(:table_name)
      raise ArgumentError.new("Includee #{model} must have both the #code attribute and the self.table_name() class method.")
    end
  end

  # Computes a localized shorter description for the value/code associated with this data
  def i18n_short
    I18n.t( "i18n_short_#{ code }".to_sym, { scope: [self.class.get_scope_sym] } )
  end

  # Computes a localized description for the value/code associated with this data
  def i18n_description
    I18n.t( "i18n_description_#{ code }".to_sym, { scope: [self.class.get_scope_sym] } )
  end

  # Computes an alternate localized shorter description for the value/code associated with this data.
  # Note that this may not always be defined inside the locale files.
  def i18n_alternate
    # TODO Add existance check for I18n.t result; when not found, return default i18n_short result.
    I18n.t( "i18n_alternate_#{ code }".to_sym, { scope: [self.class.get_scope_sym] } )
  end
  # ----------------------------------------------------------------------------

  module ClassMethods
    # Returns the scope symbol used for grouping the localization strings.
    def get_scope_sym
      table_name.to_sym
    end
  end
  # ----------------------------------------------------------------------------
end
