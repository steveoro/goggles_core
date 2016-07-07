require 'rails_helper'
require 'date'


describe MeetingEvent, :type => :model do

  context "[a non-valid instance]" do
    it_behaves_like( "(missing required values)", [
      :event_order
    ])
  end
  #-- -------------------------------------------------------------------------
  #++

  context "using a well formed factory for individual result," do
    subject { create(:meeting_event_individual) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "refers to an individual result" do
      expect( subject.event_type.is_a_relay ).to be false
    end
  end

  context "using a well formed factory for relay result," do
    subject { create(:meeting_event_relay) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "refers to a relay result" do
      expect( subject.event_type.is_a_relay ).to be true
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # This section is separated from the context below because really it's
  # more of a functional test instead of normal unit test.
  context "[a valid, pre-existing seeded domain]" do
    # It uses a just a single predetermined seed to verify the values
    subject { MeetingEvent.find(1153) }

    it_behaves_like( "MeetingAccountable",
      # These values were hand-verified for Meeting #13105, event #1153:
      1,  # team_id
      31, # tot_male_results
      18, # tot_female_results
      # (49 total MIRs)
      8,  # tot_team_results
      7,  # tot_male_entries    => (for each start-list entry or accredited time found)
      3,  # tot_female_entries
      10  # tot_team_entries
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  context "[a well formed instance]" do
    subject { create(:meeting_event) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :meeting_session,
      :event_type,
      :heat_type
    ])

    context "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty strings)", [
        :get_full_name,
        :get_verbose_name,
        :get_meeting_session_name,
        :get_meeting_session_verbose_name
      ])
      it_behaves_like( "(the existance of a method returning a date)", [
        :get_scheduled_date
      ])
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
