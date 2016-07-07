require 'rails_helper'

describe EditionType, :type => :model do
  it_behaves_like "DropDownListable"
  it_behaves_like "Localizable"
end
