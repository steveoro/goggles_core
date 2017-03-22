# encoding: utf-8


=begin

= fin_calendar

  - version:  6.00.035
  - author:   Steve A., Leega

=end
class FinCalendar < ApplicationRecord
  belongs_to :user                                  # [Steve, 20120212] Do not validate associated user!
  belongs_to :season
  validates_associated :season

  validates_presence_of :goggles_meeting_code, allow_nil: false

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------
  #++

  # Computes the shortest possible description for the name associated with this data
  def get_short_name
    column_name
  end

  # Computes a shorter description for the name associated with this data
  def get_full_name
    "#{column_date} #{column_name} #{column_place}"
  end

  # Computes a verbose or formal description for the name associated with this data
  def get_verbose_name
    "#{column_date} #{column_name} #{column_place} - #{goggles_meeting_code}"
  end
  # ----------------------------------------------------------------------------

  # Retrieve month (number) from start-list or result fin code
  # Return 0 if nor codes present
  #
  def get_month_from_code
    month_from_code = 0
    if fin_startlist_code || fin_result_code
      codice = fin_startlist_code ? fin_startlist_code : fin_result_code    
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
  
end
