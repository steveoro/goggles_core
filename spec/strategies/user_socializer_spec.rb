require 'rails_helper'


describe UserSocializer, :type => :strategy do
  before :each do
    @user = create( :user )
    @swimming_buddy = create( :user )
    @user.set_associated_swimmer( create(:swimmer) )
    @swimming_buddy.set_associated_swimmer( create(:swimmer) )
    @user_socializer = UserSocializer.new( @user )
  end

  subject { @user_socializer }

  context "[general methods]" do
    [
      :confirm_with_notify, :unconfirm_with_notify,
      :invite_with_notify,  :approve_with_notify, :remove_with_notify
    ].each do |method_name|
      it "responds to ##{method_name}" do
        expect( subject ).to respond_to( method_name )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#confirm_with_notify" do
    it "updates both sender & receiver news-feeds when successful" do
      expect{
        subject.confirm_with_notify( @swimming_buddy )
      }.to change{ NewsFeed.friend_activities.count }.by(2)
    end
  end

  describe "#unconfirm_with_notify" do
    it "updates the receiver news-feed when successful" do
      UserSwimmerConfirmation.confirm_for( @swimming_buddy, @swimming_buddy.swimmer, @user )
      expect{
        subject.unconfirm_with_notify( @swimming_buddy )
      }.to change{ NewsFeed.friend_activities.count }.by(1)
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#invite_with_notify" do
    it "updates the receiver news-feed when successful" do
      expect{
        subject.invite_with_notify( @swimming_buddy )
      }.to change{ NewsFeed.friend_activities.count }.by(1)
    end
# FIXME [Steve, 20160616] NO MAILER CALLS IN USER SOCIALIZER FOR FRAMEWORK VERS. 5+
#    it "sends the receiver a notification mail when successful" do
#      expect{
#        subject.invite_with_notify( @swimming_buddy )
#      }.to change{ NewsletterMailer.deliveries.size }
#      expect( NewsletterMailer.deliveries.last.to.first ).to include( @swimming_buddy.email )
#    end
    it "(Failing with an invited pending friendship) does not update any news-feed" do
      expect{
        @user.invite( @swimming_buddy )
        subject.invite_with_notify( @swimming_buddy )
      }.not_to change{ NewsFeed.friend_activities.count }
    end
  end

  describe "#approve_with_notify" do
    it "updates both sender & receiver news-feeds when successful" do
      @swimming_buddy.invite( @user )
      expect{
        subject.approve_with_notify( @swimming_buddy )
      }.to change{ NewsFeed.friend_activities.count }.by(2)
    end
    it "(Failing with a non-existing  friendship) does not update any news-feed" do
      expect{
        subject.approve_with_notify( @swimming_buddy )
      }.not_to change{ NewsFeed.friend_activities.count }
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  describe "#remove_with_notify" do
    it "updates the sender news-feed when successful" do
      @user.invite( @swimming_buddy )
      @swimming_buddy.approve( @user )
      expect{
        subject.remove_with_notify( @swimming_buddy )
      }.to change{ NewsFeed.friend_activities.count }.by(1)
    end
    it "(Failing with a non-existing  friendship) does not update any news-feed" do
      expect{
        subject.remove_with_notify( @swimming_buddy )
      }.not_to change{ NewsFeed.friend_activities.count }
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
