require 'rails_helper'


describe DataImportMeetingRelayResult, :type => :model do
  it_behaves_like "TimingGettable"
  #-- -------------------------------------------------------------------------
  #++

  context "[Standard Factory]" do
    subject { create(:data_import_meeting_relay_result) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    it "has a valid Team istance" do
      expect( subject.team ).to be_valid
    end
    it "has a valid DataImportMeetingProgram istance" do
      expect( subject.data_import_meeting_program ).to be_valid
    end

    it "refers to a valid Meeting istance" do
      expect( subject.meeting ).to be_valid
    end
    it "refers to a relay result" do
      expect( subject.data_import_meeting_program.event_type.is_a_relay ).to be true
    end

    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      # These are the only two actually created by the factory and
      # needed by the specs: (but none are required inside the model)
      :data_import_meeting_program,
      :team
    ])
    it_behaves_like( "(it has_one of these required models)", [
      :meeting
    ])
  end
  #-- -------------------------------------------------------------------------
  #++

  # TODO add test context for scopes (not for sorting scopes)
end
