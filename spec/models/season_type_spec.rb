# frozen_string_literal: true

require 'rails_helper'

describe SeasonType, type: :model do
  subject { create(:season_type) }

  it_behaves_like 'DropDownListable'

  # Filtering scopes:
  it_behaves_like('(the existance of a class method)', [
                    :is_master
                  ])

  it_behaves_like('(the existance of a method returning non-empty strings)', [
                    :get_full_name
                  ])
end
