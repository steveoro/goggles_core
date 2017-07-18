require 'drop_down_listable'

=begin

= EventType model

  - version:  6.111
  - author:   Steve A.

=end
class EventType < ApplicationRecord
  include DropDownListable

  belongs_to :stroke_type
  validates_presence_of :stroke_type                # (must be not null)
  validates_associated :stroke_type                 # (foreign key integrity)

  delegate :code, :i18n_short, :i18n_description, to: :stroke_type, prefix: true

  validates_presence_of   :code
  validates_length_of     :code, within: 1..10, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  validates_length_of     :length_in_meters, maximum: 12
  validates_length_of     :partecipants, maximum: 5
  validates_length_of     :phases, maximum: 5
  validates_length_of     :phase_length_in_meters, maximum: 8

  validates_presence_of     :style_order
  validates_length_of       :style_order, within: 1..3, allow_nil: false
  validates_numericality_of :style_order

  has_many :meeting_events
  has_many :meeting_sessions, through: :meeting_events
  has_many :meetings,         through: :meeting_sessions
  has_many :seasons,          through: :meetings
  has_many :season_types,     through: :seasons

  has_many :events_by_pool_types
  has_many :pool_types,       through: :events_by_pool_types

  scope :only_relays,         ->{ where(is_a_relay: true) }
  scope :are_not_relays,      ->{ where(is_a_relay: false) }
  scope :for_fin_calculation, ->{ where('((length_in_meters % 50) = 0) AND (length_in_meters <= 1500)') }

  scope :sort_by_style,       ->{ order('style_order') }

  scope :for_season,          ->(season_id)   { joins(:seasons).where(['season_id = ?', season_id]) }
  scope :for_season_type,     ->(season_type) { joins(:season_types).where(['season_types.id = ?', season_type.id]) }
  #-- -------------------------------------------------------------------------
  #++

  # Computes a localized shorter description for the value/code associated with this data
  def i18n_short
    if self.is_a_relay
      relay_name = I18n.t( (self.is_mixed_gender ? :mixed_relay_short : :relay_short), { scope: [:relay_types] } )
      "#{ self.phases }x#{ self.phase_length_in_meters } #{ self.stroke_type.i18n_short(true) } " +
      ( self.partecipants != self.phases ? "(#{relay_name}/#{self.partecipants})" : "(#{relay_name})" )
    else
      "#{self.length_in_meters} #{self.stroke_type_i18n_short}"
    end
  end

  # Computes a localized shorter description for the value/code associated with this data
  def i18n_compact
    if self.is_a_relay
      relay_name = I18n.t( (self.is_mixed_gender ? :mixed_relay_short : :relay_short), { scope: [:relay_types] } )
      "#{ self.phases }x#{ self.phase_length_in_meters }#{ self.stroke_type.i18n_short(true) } " +
      ( self.partecipants != self.phases ? "(#{relay_name}/#{self.partecipants})" : "(#{relay_name})" )
    else
      "#{self.length_in_meters}#{self.stroke_type_i18n_short}"
    end
  end

  # Computes a localized description for the value/code associated with this data
  def i18n_description
    if self.is_a_relay
      relay_name = I18n.t( (self.is_mixed_gender ? :mixed_relay : :relay), { scope: [:relay_types] } )
      "#{ self.phases }x#{ self.phase_length_in_meters } #{ self.stroke_type.i18n_description(true) } " +
      ( self.partecipants != self.phases ? "(#{relay_name} #{self.partecipants} #{I18n.t(:athletes)})" : "(#{relay_name})" )
    else
      "#{self.length_in_meters} #{self.stroke_type_i18n_description}"
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
  def self.parse_relay_event_type_from_import_text( stroke_type_id, type_text )
    is_mixed_gender = ( type_text =~ /mistaff|mix/ui ? 1 : 0 )
                                                    # NOTE: assuming type_text has a format like => "mistaffetta NxLLL farf"
    re = Regexp.new( /(\d)x(\d{2,3})\s/ui )
    match = re.match( type_text )
    raise "EventType.parse_relay_event_type_from_import_text(): unsupported type_text parameter format!" unless match.instance_of?( MatchData )
    phases, phase_length_in_meters = match.captures.map{ |e| e.to_i }

    relay_type = EventType.where(
      [
        '(is_a_relay = 1) AND (stroke_type_id = ?) AND ' +
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
  def self.sort_list_by_style_order( event_list = nil )
    @sorted_full_list = EventType.sort_by_style.map{ |event_type| event_type.code }
    if event_list
      event_list.sort!{ |el_prev, el_next| @sorted_full_list.rindex(el_prev) <=> @sorted_full_list.rindex(el_next) }
    else
      event_list = @sorted_full_list
    end
    event_list
  end
  #-- -------------------------------------------------------------------------
  #++
end
