# frozen_string_literal: true

#
# = fin_calendar
#
#   - version:  6.095
#   - author:   Steve A., Leega
#
class FinCalendar < ApplicationRecord

  # String names used to detect months:
  STANDARD_MONTH_NAMES = %w[Gennaio Febbraio Marzo Aprile Maggio Giugno Luglio Agosto Settembre Ottobre Novembre Dicembre].freeze
  #-- -------------------------------------------------------------------------
  #++

  belongs_to :user # [Steve, 20120212] Do not validate associated user!
  belongs_to :season
  belongs_to :meeting

  validates_associated :season

  validates :goggles_meeting_code, presence: { allow_nil: false }

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------
  #++

  # Computes the shortest possible description for the name associated with this data
  def get_short_name
    calendar_name
  end

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{calendar_date} #{calendar_month} #{calendar_year}, #{calendar_name} #{calendar_place}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{calendar_date} #{calendar_month} #{calendar_year}, #{calendar_name} #{calendar_place} - #{goggles_meeting_code}"
  end
  #-- -------------------------------------------------------------------------
  #++

  # Computes a pseudo-unique key for the current calendar row, using only the date
  # and place information specified as parameters.
  #
  def self.calendar_unique_key(calendar_year, calendar_month, calendar_date, calendar_place)
    # Compact the month name into a number:
    month_index = STANDARD_MONTH_NAMES.index(calendar_month.to_s.downcase.camelcase)
    # Compose a pseudo-unique key for the current calendar row among this season:
    "#{calendar_year}/#{month_index ? month_index + 1 : nil}/#{calendar_date}:#{calendar_place.gsub(/[\s\,\:\-\_\']/, '').downcase}"
  end

  # Computes a pseudo-unique key for the current calendar row, using only the date
  # and place information from the calendar row members.
  #
  def calendar_unique_key
    FinCalendar.calendar_unique_key(calendar_year, calendar_month, calendar_date, calendar_place)
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the month (number) either from the start-list or the result FIN code
  # (used in the corresponding link field but filled separately during data acquisition).
  #
  # Returns 0 if none of codes are present
  #
  def get_month_from_fin_code
    month_from_code = 0
    if fin_startlist_code || fin_results_code
      codice = fin_startlist_code || fin_results_code
      months = {}
      months['A'] = 10  # October
      months['B'] = 11  # November
      months['C'] = 12  # Dicember
      months['D'] = 1   # Jenuary
      months['E'] = 2   # February
      months['F'] = 3   # March
      months['G'] = 4   # April
      months['H'] = 5   # May
      months['I'] = 6   # June
      month_from_code = months[codice.left(1)]
    end
    month_from_code
  end
  #-- -------------------------------------------------------------------------
  #++

end
