require 'common/validation_error_tools'

FactoryBot.define do
  factory :swimmer_season_score do
    meeting_individual_result   { create(:meeting_individual_result) }
    badge                       { meeting_individual_result.badge }
    event_type                  { meeting_individual_result.event_type }
    score                       { meeting_individual_result.standard_points }
    
    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for( built_instance )
        puts built_instance.inspect
      end
    end
  end
end
#-- ---------------------------------------------------------------------------
#++
