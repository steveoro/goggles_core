# frozen_string_literal: true

require 'drop_down_listable'

#
# = EventType model
#
#   - version:  6.111
#   - author:   Steve A.
#
class EventType < ApplicationRecord

  include DropDownListable

  belongs_to :stroke_type
  validates :stroke_type, presence: true # (must be not null)
  validates_associated :stroke_type # (foreign key integrity)

  delegate :code, :i18n_short, :i18n_description, to: :stroke_type, prefix: true

  validates :code, presence: true
  validates :code, length: { within: 1..10, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }

  validates     :length_in_meters, length: { maximum: 12 }
  validates     :partecipants, length: { maximum: 5 }
  validates     :phases, length: { maximum: 5 }
  validates     :phase_length_in_meters, length: { maximum: 8 }

  validates     :style_order, presence: true
  validates :style_order, length: { within: 1..3, allow_nil: false }
  validates :style_order, numericality: true

  has_many :meeting_events
  has_many :meeting_sessions, through: :meeting_events
  has_many :meetings,         through: :meeting_sessions
  has_many :seasons,          through: :meetings
  has_many :season_types,     through: :seasons

  has_many :events_by_pool_types
  has_many :pool_types,       through: :events_by_pool_types

  scope :only_relays,         -> { where(is_a_relay: true) }
  scope :are_not_relays,      -> { where(is_a_relay: false) }
  scope :for_fin_calculation, -> { where('((length_in_meters % 50) = 0) AND (length_in_meters <= 1500)') }
  scope :for_ironmaster,      -> { where('(not is_a_relay and length_in_meters between 50 and 1500)') }

  scope :sort_by_style,       -> { order('style_order') }

  scope :for_season,          ->(season_id)   { joins(:seasons).where(['season_id = ?', season_id]) }
  scope :for_season_type,     ->(season_type) { joins(:season_types).where(['season_types.id = ?', season_type.id]) }
  #-- -------------------------------------------------------------------------
  #++

  # Computes a localized shorter description for the value/code associated with this data
  def i18n_short
    if is_a_relay
      relay_name = I18n.t((is_mixed_gender ? :mixed_relay_short : :relay_short), scope: [:relay_types])
      "#{phases}x#{phase_length_in_meters} #{stroke_type.i18n_short(true)} " +
        (partecipants != phases ? "(#{relay_name}/#{partecipants})" : "(#{relay_name})")
    else
      "#{length_in_meters} #{stroke_type_i18n_short}"
    end
  end

  # Computes a localized shorter description for the value/code associated with this data
  def i18n_compact
    if is_a_relay
      relay_name = I18n.t((is_mixed_gender ? :mixed_relay_short : :relay_short), scope: [:relay_types])
      "#{phases}x#{phase_length_in_meters}#{stroke_type.i18n_short(true)} " +
        (partecipants != phases ? "(#{relay_name}/#{partecipants})" : "(#{relay_name})")
    else
      "#{length_in_meters}#{stroke_type_i18n_short}"
    end
  end

  # Computes a localized description for the value/code associated with this data
  def i18n_description
    if is_a_relay
      relay_name = I18n.t((is_mixed_gender ? :mixed_relay : :relay), scope: [:relay_types])
      "#{phases}x#{phase_length_in_meters} #{stroke_type.i18n_description(true)} " +
        (partecipants != phases ? "(#{relay_name} #{partecipants} #{I18n.t(:athletes)})" : "(#{relay_name})")
    else
      "#{length_in_meters} #{stroke_type_i18n_description}"
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Given a localized text description from an imported text plus other key
  # parameters, returns the corresponding EventType or +nil+ when unable to parse.
  #
  # This can be used only to discriminate relays, not other event types.
  #
  # The #stroke_type_id can be parsed elsewhere, even with partial information,
  # and it will be corrected if it is the case.
  #
  def self.parse_relay_event_type_from_import_text(stroke_type_id, type_text)
    is_mixed_gender = (type_text =~ /mistaff|mix/ui ? 1 : 0)
    # NOTE: assuming type_text has a format like => "mistaffetta NxLLL farf"
    re = Regexp.new(/(\d)x(\d{2,3})\s/ui)
    match = re.match(type_text)
    raise "EventType.parse_relay_event_type_from_import_text(): unsupported type_text ('#{type_text}') parameter format!" unless match.instance_of?(MatchData)

    phases, phase_length_in_meters = match.captures.map(&:to_i)

    relay_type = EventType.where(
      [
        '(is_a_relay = 1) AND (stroke_type_id = ?) AND ' \
        '(is_mixed_gender = ?) AND (phases = ?) AND (phase_length_in_meters = ?)',
        # [Steve, 20141113] Since the stroke type may be parsed with incomplete
        # information, we need to correct the special case in which the Mixed style
        # is recognized, and change it with the proper ID:
        stroke_type_id == StrokeType::MIXED_ID ? StrokeType::MIXED_RELAY_ID : stroke_type_id,
        is_mixed_gender,
        phases,
        phase_length_in_meters
      ]
    ).first
    relay_type
  end
  #-- -------------------------------------------------------------------------
  #++

  # Sorts an array of event codes using the style order
  #
  # Params
  # - event_list: an array of event codes
  #
  # Return a sorted list
  def self.sort_list_by_style_order(event_list = nil)
    @sorted_full_list = EventType.sort_by_style.map(&:code)
    if event_list
      event_list.sort! { |el_prev, el_next| @sorted_full_list.rindex(el_prev) <=> @sorted_full_list.rindex(el_next) }
    else
      event_list = @sorted_full_list
    end
    event_list
  end
  #-- -------------------------------------------------------------------------
  #++

  # Give the CSI reservations and results event distance numeric code
  # TODO Use federation code or map corrispondence on DB
  #
  def get_csi_distance_code
    csi_code = '0'
    if length_in_meters == 25
      csi_code = '1'
    elsif length_in_meters == 50
      csi_code = '2'
    elsif length_in_meters == 100
      csi_code = '3'
    elsif length_in_meters == 200
      csi_code = '4'
    elsif length_in_meters == 400
      csi_code = '5'
    elsif length_in_meters == 800
      csi_code = '6'
    elsif length_in_meters == 1500
      csi_code = '7'
    end
    csi_code
  end
  # ----------------------------------------------------------------------------

end
