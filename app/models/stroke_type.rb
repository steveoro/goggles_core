# frozen_string_literal: true

#
# = StrokeType model
#
#   - version:  4.00.615
#   - author:   Steve A.
#
class StrokeType < ApplicationRecord

  # Unique ID used inside the DB to address the Freestyle (Crawl) StrokeType instance
  FREESTYLE_ID    = 1

  # Unique ID used inside the DB to address the Butterfly StrokeType instance
  BUTTERFLY_ID    = 2

  # Unique ID used inside the DB to address the Backstroke StrokeType instance
  BACKSTROKE_ID   = 3

  # Unique ID used inside the DB to address the Breaststroke StrokeType instance
  BREASTSTROKE_ID = 4

  # Unique ID used inside the DB to address the Mixed StrokeType instance
  MIXED_ID        = 5

  # This special case is used to describe a Mixed style in a Relay event
  # This distinction is used to obtain a proper localized description below.
  MIXED_RELAY_ID  = 10

  validates :code, presence: true
  validates :code, length: { within: 1..2, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }

  # FIXME: for Rails 4+, move required/permitted check to the controller using the model
  #  attr_accessible :code

  scope :is_eventable, -> { where(is_eventable: true) }
  # ----------------------------------------------------------------------------

  # Commodity Hash used to enlist all defined IDs and their corresponding Codes
  #
  TYPES_HASH = {
    FREESTYLE_ID => 'SL',
    BUTTERFLY_ID => 'FA',
    BACKSTROKE_ID => 'DO',
    BREASTSTROKE_ID => 'RA',
    MIXED_ID => 'MI',
    MIXED_RELAY_ID => 'MX'
  }.freeze
  # ----------------------------------------------------------------------------

  # Computes a localized shorter description for the value/code associated with this data
  def i18n_short(is_a_relay = false)
    if is_a_relay && code == TYPES_HASH[MIXED_ID] # Handle special cases:
      I18n.t(:i18n_short_M, scope: [:stroke_types])
    else
      I18n.t("i18n_short_#{code}".to_sym, scope: [:stroke_types])
    end
  end

  # Computes a localized description for the value/code associated with this data
  def i18n_description(is_a_relay = false)
    if is_a_relay && code == TYPES_HASH[MIXED_ID] # Handle special cases:
      I18n.t(:i18n_description_M, scope: [:stroke_types])
    else
      I18n.t("i18n_description_#{code}".to_sym, scope: [:stroke_types])
    end
  end
  # ----------------------------------------------------------------------------
  #++

  # Given a localized text description from an imported text,
  # returns the corresponding StrokeType or nil when not found or
  # unable to parse.
  #
  # Note that the parsing of the StrokeType for a Relay may require
  # additional steps, since the style token may not properly identify
  # a Mixed-mixed relay type. The 'Mixed' stroke style for relays is
  # *always* MIXED_RELAY_ID.
  #
  def self.parse_stroke_type_from_import_text(style_token)
    if style_token.upcase == 'S' || style_token.upcase == 'L' || style_token =~ /(stile).*|SL/ui
      StrokeType.find_by(id: FREESTYLE_ID)
    elsif style_token.upcase == 'F' || style_token =~ /(farf).*|FA/ui
      StrokeType.find_by(id: BUTTERFLY_ID)
    elsif style_token.upcase == 'D' || style_token =~ /(dorso).*|DO/ui
      StrokeType.find_by(id: BACKSTROKE_ID)
    elsif style_token.upcase == 'R' || style_token =~ /(rana).*|RA/ui
      StrokeType.find_by(id: BREASTSTROKE_ID)
    elsif style_token.upcase == 'M'
      StrokeType.find_by(id: MIXED_RELAY_ID)
    elsif style_token.upcase == 'X' || style_token =~ /(mist).*|MI/ui
      StrokeType.find_by(id: MIXED_ID)
    end
  end
  # ----------------------------------------------------------------------------

  # Give the CSI reservations and results stroke numeric code
  # TODO Use federation code or map corrispondence on DB
  #
  def get_csi_code
    csi_code = '0'
    if code == 'FA'
      csi_code = '1'
    elsif code == 'DO'
      csi_code = '2'
    elsif code == 'RA'
      csi_code = '3'
    elsif code == 'SL'
      csi_code = '4'
    elsif code == 'MI'
      csi_code = '5'
    end
    csi_code
  end
  # ----------------------------------------------------------------------------

end
