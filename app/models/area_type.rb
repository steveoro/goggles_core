# frozen_string_literal: true

class AreaType < ApplicationRecord

  validates :code, presence: { length: { maximum: 3 }, allow_nil: false }
  validates :code, uniqueness: { message: :already_exists }

  validates :name, presence: { allow_nil: false }

  belongs_to :region_type

  # Compute a verbose name composed by code and name
  def get_name_with_code
    '@{code}-@{name}'
  end

  # Label symbol corresponding to either a column name or a model method to be used
  # mainly in generating DropDown option lists.
  #
  def self.get_label_symbol
    :code
  end

end
