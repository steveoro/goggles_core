require 'rails_helper'

describe DisqualificationCodeType, :type => :model do
  it_behaves_like "DropDownListable"
  it_behaves_like "Localizable"
end
