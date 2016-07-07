require 'rails_helper'


shared_examples_for "generic news-feed row creation" do
  it "raises an error when the user_id is nil" do
    expect{ subject.class.send(@class_method_to_call, nil, 1, 'title', 'body') }.to raise_error( ActiveRecord::RecordInvalid )
  end
  it "raises an error when the title is nil" do
    expect{ subject.class.send(@class_method_to_call, 1, 1, nil, 'body') }.to raise_error( ActiveRecord::RecordInvalid )
  end

  it "adds a row when successful" do
    expect{
      subject.class.send(@class_method_to_call, 1, 1, 'title 1', 'body' )
    }.to change{ subject.class.count }.by(1)
  end
  it "adds a row with a nil friend_id" do
    expect{
      subject.class.send(@class_method_to_call, 1, nil, 'title 2', 'body' )
    }.to change{ subject.class.count }.by(1)
  end
  it "adds a row with an empty body" do
    expect{
      subject.class.send(@class_method_to_call, 1, nil, 'title 3', '' )
    }.to change{ subject.class.count }.by(1)
  end
  it "adds a row with an nil body" do
    expect{
      subject.class.send(@class_method_to_call, 1, nil, 'title 3', nil )
    }.to change{ subject.class.count }.by(1)
  end
end
#-- ---------------------------------------------------------------------------
#++


shared_examples_for "achievement news-feed creation" do
  before( :each ) do
    @user = create(:user)
    @friend = create(:user)
  end

  it "adds a row when successful" do
    expect{
      subject.class.send(@class_method_to_call, @user, @friend, 1 )
    }.to change{ subject.class.count }.by(1)
  end
end
# =============================================================================


describe NewsFeed, :type => :model do
  context "[class]" do
    it_behaves_like( "(the existance of a class method)", [
      :create_social_feed,
      :create_social_approve_feed,
      :create_social_remove_feed,
      :create_achievement_feed,
      :create_achievement_approve_feed,
      :create_achievement_confirm_feed
    ])
    #-- -----------------------------------------------------------------------
    #++

    describe "self.create_social_feed()" do
      before( :each ) { @class_method_to_call = :create_social_feed }
      it_behaves_like "generic news-feed row creation"
    end

    describe "self.create_social_approve_feed()" do
      before( :each ) do
        @user = create(:user)
        @friend = create(:user)
      end
      it "adds 2 rows when successful" do
        expect{
          subject.class.send(:create_social_approve_feed, @user, @friend )
        }.to change{ subject.class.count }.by(2)
      end
    end

    describe "self.create_social_remove_feed()" do
      before( :each ) do
        @user = create(:user)
        @friend = create(:user)
      end
      it "adds 1 row when successful" do
        expect{
          subject.class.send(:create_social_remove_feed, @user, @friend )
        }.to change{ subject.class.count }.by(1)
      end
    end


    describe "self.create_achievement_feed()" do
      before( :each ) { @class_method_to_call = :create_achievement_feed }
      it_behaves_like "generic news-feed row creation"
    end
    describe "self.create_achievement_approve_feed()" do
      before( :each ) { @class_method_to_call = :create_achievement_approve_feed }
      it_behaves_like "achievement news-feed creation"
    end
    describe "self.create_achievement_confirm_feed()" do
      before( :each ) { @class_method_to_call = :create_achievement_confirm_feed }
      it_behaves_like "achievement news-feed creation"
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  context "[a well formed instance]" do
    it "is a valid istance" do
      news_feed = create( :news_feed )
      expect( news_feed ).to be_valid
      expect( news_feed.title ).not_to be_nil
      expect( news_feed.title ).not_to be_empty
      expect( news_feed.user ).to be_valid
      expect( news_feed.friend ).to be_valid
    end

    # Filtering scopes:
    it_behaves_like( "(the existance of a class method)", [
      :unread,
      :friend_activities,
      :only_achievements,
      :newsletter_activities,
      :sort_by_user
    ])
  end
  #-- -------------------------------------------------------------------------
  #++
end
