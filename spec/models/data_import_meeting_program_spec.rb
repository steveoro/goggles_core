require 'rails_helper'


describe DataImportMeetingProgram, :type => :model do
  it_behaves_like "TimingGettable"

  # TODO
  # describe "[a non-valid instance]" do
    # it_behaves_like( "(missing required values)", [ :number ])
  # end
  #-- -------------------------------------------------------------------------
  #++

  context "using a well formed factory for individual result," do
    subject { create(:data_import_meeting_program_individual) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "refers to an individual result" do
      expect( subject.event_type.is_a_relay ).to be false
    end
  end

  context "using a well formed factory for relay result," do
    subject { create(:data_import_meeting_program_relay) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "refers to a relay result" do
      expect( subject.event_type.is_a_relay ).to be true
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "[a well formed instance]" do
    subject { create(:data_import_meeting_program) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end

    # TODO
    # Validated relations:
    # it_behaves_like( "(belongs_to required models)", [
      # :team,
      # :season,
      # :swimmer,
      # :category_type,
      # :entry_time_type
    # ])
  end
  #-- -------------------------------------------------------------------------
  #++
end
