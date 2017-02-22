require 'rails_helper'


RSpec.describe MeetingReservation, type: :model do
  it_behaves_like "SwimmerRelatable"
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
      :user
    ])

    it_behaves_like( "(the existance of a class method)", [
      # Filtering scopes:
      :is_coming
    ])

    context "[general methods]" do
      it_behaves_like( "(the existance of a method)", [
        :notes,
        :is_not_coming,
        :has_confirmed
      ])
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
