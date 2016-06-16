require 'spec_helper'

describe LockerCabinetType, :type => :model do
  it_behaves_like "DropDownListable"
  it_behaves_like "Localizable"
end
