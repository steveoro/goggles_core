# encoding: utf-8

require 'rails_helper'
require 'common/format'


describe CalendarDAO, type: :model do
  #let(:meeting)         { create(:meeting_with_sessions) }
  #let(:meeting_session) { meeting.meeting_sessions.first }
  let(:meeting)         { Meeting.find(13106) }
  let(:meeting_session) { meeting.meeting_sessions.first }

  context "MeetingSessionDAO subclass," do

    subject { CalendarDAO::MeetingSessionDAO.new( meeting_session ) }

    it_behaves_like( "(the existance of a method)", [
      :session_order, :scheduled_date, :warm_up_time, :begin_time, :events_list, :swimming_pool
    ] )

    describe "#session_order" do
      it "is the order of the session specified for the construction" do
        expect( subject.session_order ).to eq( meeting_session.session_order )
      end
    end
    describe "#scheduled_date" do
      it "is the date of the session specified for the construction" do
        expect( Format.a_date(subject.scheduled_date) ).to eq( Format.a_date(meeting_session.scheduled_date) )
      end
    end
    describe "#warm_up_time" do
      it "is the warm_up_time of the session specified for the construction" do
        expect( Format.a_time(subject.warm_up_time) ).to eq( Format.a_time(meeting_session.get_warm_up_time) )
      end
    end
    describe "#begin_time" do
      it "is the begin_time of the session specified for the construction" do
        expect( Format.a_time(subject.begin_time) ).to eq( Format.a_time(meeting_session.get_begin_time) )
      end
    end
    describe "#events_list" do
      it "is the events of the session specified for the construction" do
        expect( subject.events_list ).to eq( meeting_session.get_short_events )
      end
    end
    describe "#swimming_pool" do
      it "is the swimming_pool of the session specified for the construction" do
        expect( subject.swimming_pool ).to eq( meeting_session.swimming_pool )
      end
    end

  end
  #-- -------------------------------------------------------------------------
  #++


  context "as a valid instance," do

    subject { CalendarDAO.new( meeting ) }

    it_behaves_like( "(the existance of a method)", [
      :meeting, :meeting_sessions
    ] )

    describe "#meeting" do
      it "is the meeting specified for the construction" do
        expect( subject.meeting ).to eq( meeting )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end

