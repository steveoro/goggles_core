require 'spec_helper'


describe FriendshipDecorator, type: :model do
  before :each do
    friend_user = create( :user )
    user = create( :user )
    user.invite( friend_user, true, true, true )
    friend_user.approve( user, true, true, true )
    @friendship = user.find_any_friendship_with( friend_user )
    @decorated_friendship = FriendshipDecorator.decorate( @friendship )
  end

  it "#to_verbose_sharing shows the sharing for passages" do
    expect( @decorated_friendship.to_verbose_sharing ).to include( I18n.t('social.passages') )
  end

  it "#to_verbose_sharing shows the sharing icon for trainings" do
    expect( @decorated_friendship.to_verbose_sharing ).to include( I18n.t('social.trainings') )
  end

  it "#to_verbose_sharing shows the sharing icon for calendars" do
    expect( @decorated_friendship.to_verbose_sharing ).to include( I18n.t('social.calendars') )
  end
end
