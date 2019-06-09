# frozen_string_literal: true

require 'active_support'
require 'wrappers/timing'

#
# = EventTypeRelatable
#
#   - version:  4.00.345.20140710
#   - author:   Leega, Steve A.
#
#   Container module for interfacing common "event_type-related" info (description, code)
#   and method functions.
#
#   *ASSUMES* the existance of the event_type reference and the validity of its
#   event_type#code field.
#
module EventTypeRelatable
  extend ActiveSupport::Concern

  # Retrieves the localized Event Type ID as it is; returns 0 in case of an invalid record
  def get_event_type_id
    event_type ? event_type.id : 0
  end

  # Retrieves the localized Event Type code (short)
  def get_event_type
    event_type ? event_type.i18n_short : '?'
  end

  # Retrieves the localized Event Type alternate
  def get_event_type_alt
    event_type ? event_type.i18n_alternate : '?'
  end

  # Retrieves the localized Event Type code (full description)
  def get_event_type_description
    event_type ? event_type.i18n_description : '?'
  end

  # Retrieves the Event Type code as it is
  def get_event_type_code
    event_type ? event_type.code : '?'
  end

  # Retrieves the Event Type stroke (short)
  def get_event_type_stroke
    event_type ? event_type.stroke_type.i18n_short : '?'
  end

  # Retrieves the Event Type with distance and stroke separeted
  def get_event_type_separated(separator = ' ')
    event_type ? (event_type.length_in_meters.to_s + separator + event_type.stroke_type.i18n_short) : '?'
  end

  # Retrieves the Event Type with distance and stroke separeted
  def get_event_type_for_csi_entry
    event_type ? get_event_type_separated.gsub('MI', 'MX') : '?'
  end
  #-- -------------------------------------------------------------------------
  #++
end
