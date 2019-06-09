# frozen_string_literal: true

require 'date'
require 'ffaker'

require 'common/validation_error_tools'

FactoryBot.define do
  trait :random_season do
    edition { ((rand * 1000) % 1000).to_i } # mediumint(9), using a sequence yields validation errors
    sequence(:description) { |n| "Fake Season #{n}/#{edition}" }

    season_type               { SeasonType.all.min { rand - 0.5 } }
    edition_type              { EditionType.all.min { rand - 0.5 } }
    timing_type               { TimingType.all.min { rand - 0.5 } }

    begin_date                { Date.parse("#{2000 + ((rand * 100) % 15).to_i}-09-01") }
    end_date                  { Date.parse("#{begin_date.year + 1}-08-30") }
    header_year               { "#{begin_date.year}/#{end_date.year}" }
  end
  #-- -------------------------------------------------------------------------
  #++

  factory :season do
    random_season

    before(:create) do |built_instance|
      if built_instance.invalid?
        puts "\r\nFactory def. error => " << ValidationErrorTools.recursive_error_for(built_instance)
        puts built_instance.inspect
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end

# Quick NameSpace container for creation-tools regarding this factory.
#
module SeasonFactoryTools
  # Chooses randomly among the already existing fixtures a Season that has at
  # least a minimum number of category_types already defined.
  #
  def self.get_season_with_full_categories(min_category_types_count = 5)
    # 1) Extract pre-built fixtures that already have categories:
    season_ids_with_categories = Season.joins(:category_types)
                                       .select('seasons.id')
                                       .group('seasons.id')
                                       .having(['count(category_types.season_id) > ?', min_category_types_count])
    # 2) Choose a random season among the above list of IDs:
    Season.where(id: season_ids_with_categories).min { rand - 0.5 }
  end
end
#-- ---------------------------------------------------------------------------
#++
