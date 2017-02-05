class RegionType < ApplicationRecord

  validates_presence_of   :code, length: { maximum: 3 }, allow_nil: false
  validates_uniqueness_of :code, message: :already_exists

  validates_presence_of   :name, allow_nil: false
  
  # Compute a verbose name composed by code and name
  def get_name_with_code
    "@{code}-@{name}"
  end
  
  # Label symbol corresponding to either a column name or a model method to be used
  # mainly in generating DropDown option lists.
  #
  def self.get_label_symbol
    :code
  end
end
