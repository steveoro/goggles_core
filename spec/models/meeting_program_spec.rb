require 'rails_helper'
require 'date'


describe MeetingProgram, :type => :model do

  context "[a non-valid instance]" do
    it_behaves_like( "(missing required values)", [
      :event_order
    ])
  end
  #-- -------------------------------------------------------------------------
  #++

  context "using a well formed factory for individual result," do
    subject { create(:meeting_program_individual) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "refers to an individual result" do
      expect( subject.event_type.is_a_relay ).to be false
    end
  end

  context "using a well formed factory for relay result," do
    subject { create(:meeting_program_relay) }

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

    subject do
      # It uses a just a single predetermined seed to verify the values:
      MeetingProgram.find(3742)
    end

    it_behaves_like( "MeetingAccountable",
      # These values were hand-verified for Meeting #13105, program #3742:
      14,  # team_id              => chosen team for this program
      3,   # tot_male_results     => 3 finalists
      0,   # tot_female_results
      2,   # tot_team_results     => 2 from same team, #14
      1,   # tot_male_entries     => Ido, entry w/o result (accredited time)
      0,   # tot_female_entries
      0    # tot_team_entries     => no entries for team #14 (no accredited time given)
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  context "[a well formed instance]" do
    subject { create(:meeting_program) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :meeting_event,
      :gender_type,
      :category_type
    ])
    # Filtering scopes:
    it_behaves_like( "(the existance of a class method)", [
      :only_relays,
      :are_not_relays
    ])

    context "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty strings)", [
        :get_short_name,
        :get_full_name,
        :get_verbose_name,
        :get_event_name,
        :get_complete_event_name,
        :get_verbose_event_name,
        :get_category_and_gender_short
      ])
      # Leega. TODO
      # More methods to check and classify

      it_behaves_like( "(the existance of a method returning a date)", [
        :get_scheduled_date
      ])
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
