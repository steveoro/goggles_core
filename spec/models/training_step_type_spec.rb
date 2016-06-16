require 'spec_helper'

describe TrainingStepType, :type => :model do
  it_behaves_like "DropDownListable"
  it_behaves_like "Localizable"

  # Filtering scopes:
  it_behaves_like( "(the existance of a class method)", [
    :sort_by_step_order
  ])
end
