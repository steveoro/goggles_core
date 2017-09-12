require 'rails_helper'


describe DataImportMeetingTeamScore, :type => :model do
  # TODO
  # describe "[a non-valid instance]" do
    # it_behaves_like( "(missing required values)", [ :number ])
  # end
  #-- -------------------------------------------------------------------------
  #++

  # This is mainly used to test the factory and its relationships:
  context "[Standard Factory]" do
    subject { create(:data_import_meeting_team_score) }
    it_behaves_like( "a valid instance having a valid Season, Meeting and Team (+Affiliation)" )
  end


  context "[Factory 'with_relay_results']" do
    subject { create(:data_import_meeting_team_score_with_relay_results) }
    it_behaves_like( "a valid instance having a valid Season, Meeting and Team (+Affiliation)" )

    it "creates at least 1 MeetingSession" do
      expect( subject.meeting.meeting_sessions.count ).to be >= 1
    end
    it "creates only valid MeetingSessions" do
      subject.meeting.meeting_sessions.each do |meeting_session|
        expect( meeting_session ).to be_valid
      end
    end

    it "creates at least 1 MeetingEvent" do
      expect( subject.meeting.meeting_events.count ).to be >= 1
    end
    it "creates only valid MeetingEvents" do
      subject.meeting.meeting_events.each do |meeting_event|
        expect( meeting_event ).to be_valid
      end
    end

    it "creates at least 1 DataImportMeetingProgram" do
      di_mprgs = DataImportMeetingProgram.joins(:meeting).includes(:meeting).where( "meetings.id = ?", subject.meeting_id )
      expect( di_mprgs.count ).to be >= 1
    end
    it "creates only valid DataImportMeetingPrograms" do
      di_mprgs = DataImportMeetingProgram.joins(:meeting).includes(:meeting).where( "meetings.id = ?", subject.meeting_id )
      di_mprgs.each do |di_mprg|
        expect( di_mprg ).to be_valid
      end
    end

    it "creates at least 1 DataImportMeetingRelayResult" do
      di_mprgs = DataImportMeetingRelayResult.joins(:meeting).includes(:meeting).where( "meetings.id = ?", subject.meeting_id )
      expect( di_mprgs.count ).to be >= 1
    end
    it "creates only valid DataImportMeetingRelayResult" do
      di_mprgs = DataImportMeetingRelayResult.joins(:meeting).includes(:meeting).where( "meetings.id = ?", subject.meeting_id )
      di_mprgs.each do |di_mprg|
        expect( di_mprg ).to be_valid
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
