require 'rails_helper'

RSpec.describe RegionType, type: :model do
  it_behaves_like "DropDownListable"
  it_behaves_like "Localizable"
end
