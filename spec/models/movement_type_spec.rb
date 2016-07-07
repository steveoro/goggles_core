require 'rails_helper'

describe MovementType, :type => :model do
  it_behaves_like "DropDownListable"
  it_behaves_like "Localizable"
end
