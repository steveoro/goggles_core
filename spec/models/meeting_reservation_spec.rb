require 'spec_helper'

RSpec.describe MeetingReservation, :type => :model do
  it_behaves_like "SwimmerRelatable"
  it_behaves_like "TimingGettable"
  #-- -------------------------------------------------------------------------
  #++

  context "[a well formed instance]" do
    subject { create(:meeting_reservation) }

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
  end
  #-- -------------------------------------------------------------------------
  #++
end
