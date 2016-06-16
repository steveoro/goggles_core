require 'spec_helper'

describe PoolType, :type => :model do
  # Assumes presence in seeds
  subject { PoolType.find( ((rand * 100) % PoolType.count).to_i + 1 ) }

  it_behaves_like "DropDownListable"

  # Filtering scopes:
  it_behaves_like( "(the existance of a class method)", [
    :only_for_meetings
  ])
  # Has_many relationships:
  it_behaves_like( "(the existance of a method returning a collection of some kind of instances)",
    [ 
      :events_by_pool_types,
      :event_types
    ],
    ActiveRecord::Base
  )
      
  it_behaves_like( "(the existance of a method returning non-empty strings)", [ 
    :i18n_short,
    :i18n_description,
    :i18n_verbose
  ])
end
