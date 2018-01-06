require 'date'
require 'ffaker'

require 'common/validation_error_tools'


FactoryBot.define do

  factory :meeting do
    sequence( :code )         { |n| "meeting-#{n}" }
    description               { "#{FFaker::Name.suffix} #{FFaker::Address.city} Meeting" }
    edition                   { ((rand * 100) % 40).to_i }
    season                    { Season.is_ended.order('RAND()').first }
    header_date               { season.begin_date + (rand * 100).to_i.days }
    header_year               { season.header_year }
    edition_type              { EditionType.all.sample }
    timing_type               { TimingType.all.sample }
    user

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for( built_instance )
        puts built_instance.inspect
      end
    end

    factory :meeting_with_sessions do
      after(:create) do |created_instance, evaluator|
        create_list(
          :meeting_session,
          ((rand * 10) % 2).to_i + 1,
          meeting: created_instance            # association enforce for each sub-row
        )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
