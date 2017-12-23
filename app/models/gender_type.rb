require 'drop_down_listable'
require 'localizable'



=begin

= GenderType model

  - version:  4.00.681
  - author:   Steve A.

=end
class GenderType < ApplicationRecord
  include DropDownListable
  include Localizable

  validates_presence_of   :code, length: { maximum: 1 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  scope :individual_only,   -> { where( "(gender_types.code != 'X')" ) }
  scope :sort_by_courtesy,  -> { order( 'code' ) }

  # Unique ID used inside the DB to address the Male GenderType instance
  MALE_ID   = 1

  # Unique ID used inside the DB to address the Female GenderType instance
  FEMALE_ID = 2

  # Unique ID used inside the DB to address the Mixed/"Don't care" GenderType instance
  MIXED_OR_ANY_ID = 3
  # ----------------------------------------------------------------------------

  # Commodity Hash used to enlist all defined IDs and their corresponding Codes
  #
  TYPES_HASH = {
    MALE_ID   => 'M',
    FEMALE_ID => 'F',
    MIXED_OR_ANY_ID => 'X'
  }
  # ----------------------------------------------------------------------------

  # Returns true if the current row's ID is equal to MALE_ID
  def is_male
    ( self.id == MALE_ID )
  end

  # Returns true if the current row's ID is equal to FEMALE_ID
  def is_female
    ( self.id == FEMALE_ID )
  end
  # ----------------------------------------------------------------------------

  # Given a localized text description from an imported text.
  # == Returns:
  # the corresponding GenderType or GenderType.find_by_code('X')
  # when unable to parse.
  #
  def self.parse_gender_type_from_import_text( gender_token )
    if gender_token.upcase == 'M' || gender_token =~ /maschi/ui
      GenderType.find_by_code('M')
    elsif gender_token.upcase == 'F' || gender_token =~ /femmi/ui
      GenderType.find_by_code('F')
    else
      GenderType.find_by_code('X')
    end
  end
  # ----------------------------------------------------------------------------

  # Give a verbose (localized) desription of gender by uisp code
  # N.B. The UISP code is the same used as gender_type code
  #
  # Returns '? if no gender corrispondence to given code
  #
  def self.retrieve_description_by_uisp_code( uisp_code )
    gender_type_desc = '?'
    if GenderType.exists?( :code => uisp_code.upcase )
      gender_type = GenderType.find_by_code( uisp_code.upcase )
      gender_type_desc = gender_type.i18n_description
    end
    gender_type_desc  
  end
  # ----------------------------------------------------------------------------

  # Give the CSI reservations and results gender numeric code
  # TODO Use federation code or map corrispondence on DB
  #
  def get_csi_code
    csi_code = '-1'
    if code == 'M'
      csi_code = '1'
    elsif code == 'F'
      csi_code = '0'
    end
    csi_code  
  end
  # ----------------------------------------------------------------------------
end
