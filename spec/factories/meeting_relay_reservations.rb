FactoryGirl.define do
  factory :meeting_relay_reservation do
    meeting               { Meeting.has_results.joins(:event_types).includes(:event_types).where('event_types.is_a_relay' => true).distinct.sort{ rand - 0.5 }[0] }
    team                  { badge.team }
    swimmer               { badge.swimmer }
    badge                 { Badge.all.sort{ rand - 0.5 }[0] }
    meeting_event         { meeting.meeting_events.only_relays.sort{ rand - 0.5 }[0] }
    user

    is_doing_this         true
    notes                 nil
  end
end
