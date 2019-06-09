# frozen_string_literal: true

require 'rails_helper'

describe HairDryerType, type: :model do
  it_behaves_like 'DropDownListable'
  it_behaves_like 'Localizable'
end
