require 'rails_helper'


RSpec.describe MeetingEventReservation, type: :model do
  it_behaves_like "SwimmerRelatable"
  it_behaves_like "TimingGettable"
  #-- -------------------------------------------------------------------------
  #++

  context "[a well formed instance]" do
    subject { create(:meeting_event_reservation) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end

    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :meeting,
      :team,
      :swimmer,
      :badge,
      :meeting_event,
      :user
    ])

    it_behaves_like( "(it has_one of these required models)", [
      :season,
      :season_type,
      :event_type,
      :meeting_session,
      :category_type,
      :gender_type
    ])

    context "[general methods]" do
      it_behaves_like( "(the existance of a method)", [
        :suggested_minutes, :suggested_seconds, :suggested_hundreds,
        :minutes, :seconds, :hundreds,
        :is_doing_this
      ])
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#is_not_registered" do
      context "for an instance with a nil timing," do
        subject do
          MeetingEventReservation.new
        end
        it "returns true" do
          expect( subject.is_not_registered ).to be true
        end
      end
      context "for an instance with a zero timing," do
        subject do
          MeetingEventReservation.new( suggested_minutes: 0, suggested_seconds: 0, suggested_hundreds: 0)
        end
        it "returns false" do
          expect( subject.is_not_registered ).to be false
        end
      end
      context "for an instance with a positive timing," do
        subject do
          build(:meeting_event_reservation)
        end
        it "returns false" do
          expect( subject.is_not_registered ).to be false
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#meeting_program" do
      context "for reservations of 'closed' meetings," do
        # Use a well-defined, pre-existing fixture, with already imported results:
        subject { MeetingEventReservation.order('id ASC').limit(100).select{|e| e.meeting_program != nil }.sort{rand - 0.5}.first }

        it "returns a MeetingProgram" do
          expect( subject.meeting_program ).to be_a( MeetingProgram )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
