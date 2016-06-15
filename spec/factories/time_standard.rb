require 'date'
require 'ffaker'

require 'common/validation_error_tools'


FactoryGirl.define do

  factory :time_standard do
    season
    gender_type_id            { ((rand * 100) % 2).to_i + 1 }  # ASSERT: at least 2 gender types
    pool_type_id              { ((rand * 100) % 2).to_i + 1 }  # ASSERT: 25 and 50 meters type should exists
    category_type_id          { ((rand * 100) % 20).to_i + 1 } # ASSERT: at least 20 category types
    event_type_id             { ((rand * 100) % 18).to_i + 1} # ASSERT: at least 18 event types
    minutes                   { ((rand * 10) % 10).to_i }
    seconds                   { ((rand * 59) % 59).to_i }     # Force not to use 59
    hundreds                  { ((rand * 99) % 99).to_i + 1}  # Force not to use 0 or 99

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for( built_instance )
        puts built_instance.inspect
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
