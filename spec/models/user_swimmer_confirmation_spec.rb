require 'spec_helper'


describe UserSwimmerConfirmation, :type => :model do
  context "[class]" do
    before( :each ) do
      @swimmer = create( :swimmer )
      @user = create( :user )
      @confirmator = create( :user )
    end

    it_behaves_like( "(the existance of a class method)", [
      # Filtering scopes:
      :find_for_user,
      :find_for_confirmator,
      :find_any_between,
      # Other class methods:
      :confirm_for,
      :unconfirm_for
    ])
    #-- -----------------------------------------------------------------------
    #++

    describe "self.confirm_for()" do
      it "returns an instance of the confirmation row when successful" do
        expect( subject.class.confirm_for(@user, @swimmer, @confirmator) ).to be_an_instance_of(UserSwimmerConfirmation)
      end

      it "adds a row when successful" do
        expect{
          subject.class.confirm_for( @user, @swimmer, @confirmator )
        }.to change{ subject.class.count }.by(1)
      end

      it "returns the added row when successful" do
        result = subject.class.confirm_for(@user, @swimmer, @confirmator)
        expect( result ).to be_an_instance_of(UserSwimmerConfirmation)
        expect( result.user_id ).to eq(@user.id)
        expect( result.swimmer_id ).to eq(@swimmer.id)
        expect( result.confirmator_id ).to eq(@confirmator.id)
      end

      it "sucessfully adds a new, different confirmation" do
        confirmation = create( :user_swimmer_confirmation ) # (same user & swimmer, different confirmator)
        expect( subject.class.confirm_for(confirmation.user, confirmation.swimmer, @user) ).to be_an_instance_of(UserSwimmerConfirmation)
      end

      it "returns nil when the same confirmation already exists" do
        confirmation = create( :user_swimmer_confirmation )
        expect( subject.class.confirm_for(confirmation.user, confirmation.swimmer, confirmation.confirmator) ).to be_nil
      end

      it "returns nil on parameter error" do
        expect( subject.class.confirm_for( nil, @swimmer, @confirmator) ).to be_nil
        expect( subject.class.confirm_for( @user, nil, @confirmator) ).to be_nil
        expect( subject.class.confirm_for( @user, @swimmer, nil) ).to be_nil
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "self.unconfirm_for()" do
      it "is truthy when the association exists" do
        confirmation = create( :user_swimmer_confirmation )
        expect(
          subject.class.unconfirm_for(confirmation.user, confirmation.swimmer, confirmation.confirmator)
        ).to be_truthy
      end

      it "removes a row when successful" do
        confirmation = create( :user_swimmer_confirmation )
        expect{
          subject.class.unconfirm_for(confirmation.user, confirmation.swimmer, confirmation.confirmator)
        }.to change{ subject.class.count }.by(-1)
      end

      it "is falsey when the association does not exist" do
        expect( subject.class.unconfirm_for(@user, @swimmer, @confirmator) ).to be_falsey
      end

      it "is falsey on parameter error" do
        confirmation = create( :user_swimmer_confirmation )
        expect( subject.class.unconfirm_for(nil, confirmation.swimmer, confirmation.confirmator) ).to be_falsey
        expect( subject.class.unconfirm_for(confirmation.user, nil, confirmation.confirmator) ).to be_falsey
        expect( subject.class.unconfirm_for(confirmation.user, confirmation.swimmer, nil) ).to be_falsey
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "self.find_for_user() scope" do
      before( :each ) do
        @swimmer2 = create( :swimmer )
        @user2    = create( :user )
        @confirmator2 = create( :user )
        @confirmation1a = subject.class.confirm_for(@user, @swimmer, @confirmator)
        @confirmation1b = subject.class.confirm_for(@user, @swimmer, @confirmator2)
        @confirmation1c = subject.class.confirm_for(@user, @swimmer, @user2)
      end

      it "returns a list of UserSwimmerConfirmation having the specified user" do
        scoped_rows = subject.class.find_for_user( @user )
        expect( scoped_rows ).to respond_to( :size )
        expect( scoped_rows.size ).to eq(3)
        expect( scoped_rows[0] ).to be_an_instance_of( UserSwimmerConfirmation )
        expect( scoped_rows[1] ).to be_an_instance_of( UserSwimmerConfirmation )
        expect( scoped_rows[2] ).to be_an_instance_of( UserSwimmerConfirmation )
      end

      it "returns an empty list with a not found user" do
        scoped_rows = subject.class.find_for_user( @confirmator )
        expect( scoped_rows ).to be_empty
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "self.find_for_confirmator() scope" do
      before( :each ) do
        @swimmer2 = create( :swimmer )
        @user2    = create( :user )
        @confirmator2 = create( :user )
        @confirmation1a = subject.class.confirm_for(@user, @swimmer, @confirmator)
        @confirmation1b = subject.class.confirm_for(@user, @swimmer, @confirmator2)
        @confirmation1c = subject.class.confirm_for(@user, @swimmer, @user2)
      end

      it "returns a list of UserSwimmerConfirmation having the specified confirmator" do
        scoped_rows = subject.class.find_for_confirmator( @confirmator )
        expect( scoped_rows ).to respond_to( :size )
        expect( scoped_rows.size ).to eq(1)
        expect( scoped_rows[0] ).to be_an_instance_of( UserSwimmerConfirmation )
      end

      it "returns an empty list with a not found confirmator" do
        scoped_rows = subject.class.find_for_confirmator( @user )
        expect( scoped_rows ).to be_empty
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "self.find_any_between() scope" do
      before( :each ) do
        @confirmation1a = subject.class.confirm_for(@user, @swimmer, create(:user))
        @confirmation1b = subject.class.confirm_for(@user, @swimmer, @confirmator)
        @confirmation1c = subject.class.confirm_for(create(:user), create(:swimmer), @confirmator)
      end

      it "returns a list with a single UserSwimmerConfirmation found for an existing key tuple" do
        scoped_rows = subject.class.find_any_between( @user, @confirmator )
        expect( scoped_rows ).to respond_to( :size )
        expect( scoped_rows.size ).to eq(1)
        expect( scoped_rows[0] ).to be_an_instance_of( UserSwimmerConfirmation )
      end

      it "returns an empty list with an invalid key tuple" do
        scoped_rows = subject.class.find_any_between( @confirmator, @user )
        expect( scoped_rows ).to be_empty
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++


  context "[a well formed instance]" do
    it "is a valid istance" do
      confirmation = create( :user_swimmer_confirmation )
      expect( confirmation ).to be_valid
      expect( confirmation.user ).to be_valid
      expect( confirmation.swimmer ).to be_valid
      expect( confirmation.confirmator ).to be_valid
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
