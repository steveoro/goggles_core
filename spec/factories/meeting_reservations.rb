FactoryBot.define do
  factory :meeting_reservation do
    meeting               { Meeting.has_results.sort{ rand - 0.5 }[0] }
    team                  { badge.team }
    swimmer               { badge.swimmer }
    badge                 { Badge.all.sort{ rand - 0.5 }[0] }
    user
    notes                 { FFaker::Lorem.paragraph }
    is_not_coming         false
    has_confirmed         false
  end
end
