require 'rails_helper'


describe BadgePayment, :type => :model do
  describe "[a non-valid instance]" do
    it_behaves_like( "(missing required values)", [ :amount, :payment_date ])
  end
  #-- -------------------------------------------------------------------------
  #++

  context "[a well formed instance]" do
    subject { create(:badge_payment) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end
    # Validated relations:
    it_behaves_like( "(belongs_to required models)", [
      :badge
    ])

    # Additional instance helpers:
    [
      :swimmer,
      :season,
      :team
    ].each do |method|
      it "responds to #{ method }" do
        expect( subject ).to respond_to( method )
      end
    end

    # Filtering scopes:
    it_behaves_like( "(the existance of a class method)", [
      :sort_by_user,
      :sort_by_date,

      :for_badge,
      :for_swimmer,
      :for_team
    ])

    context "[general methods]" do
      it_behaves_like( "(the existance of a method returning non-empty strings)", [
        :get_full_name
      ])
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
