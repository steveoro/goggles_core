require 'rails_helper'

describe FederationType, :type => :model do

  subject { create( :federation_type ) }

  it_behaves_like "DropDownListable"

  it_behaves_like( "(the existance of a method returning non-empty strings)", [
    :get_short_name, :get_full_name
  ])
end
