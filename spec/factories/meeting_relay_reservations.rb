# frozen_string_literal: true

FactoryBot.define do
  factory :meeting_relay_reservation do
    meeting               { Meeting.has_results.joins(:event_types).includes(:event_types).where('event_types.is_a_relay' => true).distinct.min { rand - 0.5 } }
    team                  { badge.team }
    swimmer               { badge.swimmer }
    badge                 { Badge.all.min { rand - 0.5 } }
    meeting_event         { meeting.meeting_events.only_relays.min { rand - 0.5 } }
    user

    is_doing_this         true
    notes                 nil
  end
end
