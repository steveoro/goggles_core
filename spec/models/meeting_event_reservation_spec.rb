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

    context "[general methods]" do
      it_behaves_like( "(the existance of a method)", [
        :suggested_minutes, :suggested_seconds, :suggested_hundreds,
        :minutes, :seconds, :hundreds
      ])
    end

    describe "is_not_registered" do
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
  end
  #-- -------------------------------------------------------------------------
  #++
end
