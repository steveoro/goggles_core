require 'rails_helper'


RSpec.describe MeetingRelayReservation, type: :model do
  it_behaves_like "SwimmerRelatable"
  #-- -------------------------------------------------------------------------
  #++

  context "[a well formed instance]" do
    subject { create(:meeting_relay_reservation) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end

    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :meeting,
      :team,
      :swimmer,
      :badge,
      :user,
      :meeting_event
    ])

    context "[general methods]" do
      it_behaves_like( "(the existance of a method)", [
        :notes,
        :is_doing_this
      ])
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
