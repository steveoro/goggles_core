# frozen_string_literal: true

FactoryBot.define do
  factory :meeting_reservation do
    meeting               { Meeting.has_results.min { rand - 0.5 } }
    team                  { badge.team }
    swimmer               { badge.swimmer }
    badge                 { Badge.all.min { rand - 0.5 } }
    user
    notes                 { FFaker::Lorem.paragraph }
    is_not_coming         false
    has_confirmed         false
  end
end
