class EventsByPoolType < ApplicationRecord

  belongs_to :pool_type
  validates_presence_of :pool_type                  # (must be not null)
  validates_associated :pool_type                   # (foreign key integrity)

  belongs_to :event_type
  validates_presence_of :event_type                 # (must be not null)
  validates_associated :event_type                  # (foreign key integrity)

  has_one :stroke_type, through: :event_type

  delegate :code, :length_in_meters, :is_a_relay, :i18n_short, :i18n_description, :to => :event_type, :prefix => true
  delegate :code, :length_in_meters, :is_suitable_for_meetings, :i18n_description, :i18n_verbose, :to => :pool_type, :prefix => true
  delegate :code, :i18n_description, :to => :stroke_type, :prefix => true

  scope :are_relays,         -> { joins(:event_type).where('event_types.is_a_relay = true') }
  scope :not_relays,         -> { joins(:event_type).where('event_types.is_a_relay = false') }
  scope :only_for_meetings,  -> { joins(:pool_type).where('pool_types.is_suitable_for_meetings = true') }
  scope :for_pool_type_code, ->(pool_type_code) { joins(:pool_type).where(['pool_types.code = ?', pool_type_code]) }
  scope :distance_more_than, ->(length) { joins(:event_type).where(['event_types.length_in_meters >= ?', length]) }
  scope :distance_less_than, ->(length) { joins(:event_type).where(['event_types.length_in_meters <= ?', length]) }

  scope :sort_by_pool,       -> { joins(:event_type, :pool_type).order('pool_types.length_in_meters, event_types.style_order') }
  scope :sort_by_event,      -> { joins(:event_type, :pool_type).order('event_types.style_order, pool_types.length_in_meters') }
  # ----------------------------------------------------------------------------

  # Returns a short description for the event by pool
  #
  def i18n_short
    "#{event_type.i18n_short}-#{pool_type.i18n_short}"
  end

  # Returns a full description for the event by pool
  #
  def i18n_description
    "#{event_type.i18n_description} - #{pool_type.i18n_description}"
  end
  # ----------------------------------------------------------------------------

  # Find a sopecific event for a pool type using codes
  #
  def self.find_by_pool_and_event_codes( pool_type_code, event_type_code )
    result = EventsByPoolType.joins(:event_type, :pool_type).where( ['(pool_types.code = ?) AND (event_types.code = ?)', pool_type_code, event_type_code] )
    result ? result.first : nil
  end

  # Gets a key formed with event code and pool code
  #
  def get_key
    "#{self.event_type_code}-#{self.pool_type_code}"
  end

  # Find a sopecific event for a pool type using a key formed by event code '-' pool code
  #
  def self.find_by_key( key, separator = '-' )
    codes = key.split(separator)
    codes.size == 2 ? self.find_by_pool_and_event_codes( codes[1], codes[0] ) : nil
  end
  # ----------------------------------------------------------------------------

  # Return the event types for a given pool type code
  #
  def self.get_event_types_for_pool_type_by_code(pool_type_code)
    PoolType.find_by_code(pool_type_code).event_types
  end

  # Return the pool types for a given event type code
  #
  def self.get_pool_types_for_event_type_by_code(event_type_code)
    EventType.find_by_code(event_type_code).pool_types
  end

  # Leega TODO Implements that method correctly, if it's necessary
  # Return an hash with pool type id and all event types related
  #
  def self.get_events_by_pool_type_array
    events_by_pool_type_array = {}
    PoolType.only_for_meetings.each do |pool_type|
      event_by_pool_type_ids = EventsByPoolType.not_relays
        .where( pool_type_id: pool_type.id )
        .select( :event_type_id )
      events_by_pool_type_array[ pool_type.id ] = EventType.where( id: event_by_pool_type_ids )
    end
    events_by_pool_type_array
  end

  alias_method :get_full_name, :i18n_short
  alias_method :get_verbose_name, :i18n_description
  # ----------------------------------------------------------------------------
end

