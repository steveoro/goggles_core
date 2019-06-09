# frozen_string_literal: true

require 'active_support'
require 'wrappers/timing'

#
# = TimingGettable
#
# - version:  4.00.219.20140413
#   - author:   Steve A.
#
#   Concern that adds validations to the timing fields: :minutes, :seconds & :hundreds
#
module TimingValidatable
  extend ActiveSupport::Concern

  included do
    validates_presence_of     :minutes
    validates_length_of       :minutes, within: 1..3, allow_nil: false
    validates_numericality_of :minutes
    validates_presence_of     :seconds
    validates_length_of       :seconds, within: 1..2, allow_nil: false
    validates_numericality_of :seconds
    validates_presence_of     :hundreds
    validates_length_of       :hundreds, within: 1..2, allow_nil: false
    validates_numericality_of :hundreds
  end
end
