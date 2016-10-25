# encoding: utf-8
require 'drop_down_listable'
require 'date'


=begin

= CategoryType model

  - version:  4.00.719
  - author:   Steve A.

=end
class CategoryType < ApplicationRecord
  include DropDownListable

  validates_presence_of :code, length: { within: 1..7 }, allow_nil: false

  validates_length_of   :federation_code, within: 1..2
  validates_length_of   :description,     maximum: 100
  validates_length_of   :short_name,      maximum: 50
  validates_length_of   :group_name,      maximum: 50

  validates_length_of   :age_begin,       maximum: 3
  validates_length_of   :age_end,         maximum: 3

  belongs_to            :season
  validates_presence_of :season                     # (must be not null)
  validates_associated  :season                     # (foreign key integrity)

  has_one :season_type, through: :season
  has_one :federation_type, through: :season_type

  scope :is_valid,        -> { where(is_out_of_race: false) }
  scope :only_relays,     -> { where(is_a_relay: true) }
  scope :are_not_relays,  -> { where(is_a_relay: false) }
  scope :is_divided,      -> { where(is_undivided: false) }

  scope :sort_by_age,     ->(dir = 'ASC') { order("age_begin #{dir.to_s}") }

  scope :for_season_type, ->(season_type) { joins(:season_type).where(['season_types.id = ?', season_type.id]) }
  scope :for_season,      ->(season)      { where(['season_id = ?', season.id]) }

# FIXME for Rails 4+, move required/permitted check to the controller using the model
#  attr_accessible :code, :federation_code, :description, :short_name, :group_name, :age_begin, :age_end,
#                  :season_id, :is_a_relay, :is_out_of_race, :is_undivided
  # ----------------------------------------------------------------------------


  # Label symbol corresponding to either a column name or a model method to be used
  # mainly in generating DropDown option lists.
  #
  # @overload inherited from DropDownListable
  #
  def self.get_label_symbol
    :code
  end
  # ----------------------------------------------------------------------------

  # ----------------------------------------------------------------------------
  # Base methods:
  # ----------------------------------------------------------------------------
  #++

  # Computes the shortest possible description for the name associated with this data
  def get_short_name
    self.short_name
  end

  # Computes the shortest possible description for the name associated with this data
  def get_full_name
    self.description
  end

  # Computes the shortest possible description for the name associated with this data
  def get_verbose_name
    "#{self.federation_type.get_short_name} #{self.description} (#{self.age_begin}-#{self.age_end})"
  end
  # ----------------------------------------------------------------------------

  # Check if a given age is in the category range
  # True if the age is >= age_begin and <= age_end
  #
  def is_age_in_category( age_to_check )
    (age_to_check >= self.age_begin and age_to_check <= self.age_end)
  end
  # ----------------------------------------------------------------------------

  # Returns the corresponding id given season type id, year of birth and
  # chosen year for the result; 0 on error/not found.
  #
  def self.get_id_from( season_id, year_of_birth, chosen_date = Date.today )
    category_type = CategoryType.get_category_from( season_id, year_of_birth, chosen_date )
    category_type ? category_type.id : 0
  end

  # Returns the corresponding CategoryType given season type id, year of birth and
  # chosen year for the result; nil on error/not found.
  #
  def self.get_category_from( season_id, year_of_birth, chosen_date = Date.today )
    season = Season.find_by_id(season_id)
    if season && (season.end_date.year > chosen_date.year)
      target_age = chosen_date.year.to_i - year_of_birth.to_i + 1
    else
      target_age = chosen_date.year.to_i - year_of_birth.to_i
    end
# DEBUG
#    puts "\r\n--- target_age = #{target_age}\r\n"
    category_type = CategoryType.is_divided.includes( :season ).where(
      [
        '(season_id = ?) AND ' +
        '(category_types.age_begin <= ?) AND ' +
        '(category_types.age_end >= ?)',
        season_id, target_age, target_age
      ]
    ).first
    category_type
  end
  # ----------------------------------------------------------------------------


  # Given a localized text description from an imported text,
  # returns the corresponding CategoryType or nil when unable
  # to parse or not found.
  #
  def self.parse_category_type_from_import_text( season_id, category_token )
    result_code = ''
    query = '(season_id = ?) AND (category_types.code = ?)'
                                                    # NOTE: assuming 'Master YY'|'Under 25' format is used:
    if idx = (category_token =~ /\d\d\d\-\d\d\d/ui)
      result_code = category_token[ idx .. idx+6 ]

    elsif idx = (category_token =~ /\d\d\d/ui)
      result_code = "%#{ category_token[ idx .. idx+2 ] }%"
      query = '(season_id = ?) AND (category_types.code LIKE ?)'

    elsif idx = category_token =~ /m/ui
      result_code = 'M'
      idx = category_token =~ /\d\d/ui
      subtokens = category_token[ idx .. idx+1 ]
      result_code << subtokens if subtokens.size > 0

    elsif category_token =~ /u/ui
      result_code = 'U25'
    end
# DEBUG
#    puts "=> CategoryType.parse_category_type_from_import_text( #{season_id}, '#{category_token}' ):\t\tresult_code='#{result_code}'"
    category_type =  CategoryType.where( [ query, season_id, result_code ] ).first
    category_type
  end
  # ----------------------------------------------------------------------------
end
