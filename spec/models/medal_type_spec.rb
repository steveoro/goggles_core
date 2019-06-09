# frozen_string_literal: true

require 'rails_helper'

describe MedalType, type: :model do
  # Assumes presence in seeds
  subject { MedalType.find(((rand * 100) % MedalType.count).to_i + 1) }

  it_behaves_like 'Localizable'
  it_behaves_like 'DropDownListable'

  # Filtering scopes:
  it_behaves_like('(the existance of a class method)', [:are_not_jokes, :sort_by_rank])

  it_behaves_like('(the existance of a method returning strings)', [
                    :get_medal_tag
                  ])
end
