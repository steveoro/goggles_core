require 'rails_helper'


shared_examples_for "(an action allowed only to different users)" do |method_name_array, parameter, description|
  method_name_array.each do |method_name|
    context "as #{description}," do
      it "returns false" do
        expect( subject.send(method_name.to_sym, parameter) ).to be false
      end
    end
  end
end
# =============================================================================


describe SwimmerUserStrategy, type: :strategy do
  before :each do
    @user = create( :user )
    @user2 = create( :user )
    @user_not_associated = create( :user )
    @swimmer = create( :swimmer )
    @user.set_associated_swimmer( @swimmer )
    @swimmer2 = create( :swimmer )
    @user2.set_associated_swimmer( @swimmer2 )
    @swimmer_user_strategy = SwimmerUserStrategy.new( @swimmer )
  end

  subject { @swimmer_user_strategy }

  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method with parameters, returning boolean values)",
      [
        :is_associated_to_somebody_else_than,
        :is_confirmable_by,
        :is_unconfirmable_by,
        :is_invitable_by,
        :is_pending_for,
        :is_approvable_by,
        :is_blockable_by,
        :is_unblockable_by,
        :is_editable_by
      ],
      @user
    )
  end


  describe "#is_associated_to_somebody_else_than" do
    context "(a different user)," do
      it "returns true" do
        expect( subject.is_associated_to_somebody_else_than(@user2) ).to be true
      end
    end
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_associated_to_somebody_else_than ], @user, "the same user"
    )
  end
  # ---------------------------------------------------------------------------


  describe "#is_confirmable_by" do
    context "(a different user)," do
      it "returns true for an unconfirmed swimmer" do
        expect( subject.is_confirmable_by(@user2) ).to be true
      end
      it "returns false for an already confirmed swimmer" do
        UserSwimmerConfirmation.confirm_for( @user, @swimmer, @user2 )
        expect( subject.is_confirmable_by(@user2) ).to be false
      end
    end
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_confirmable_by ], @user, "the same user"
    )
    context "(the same current user)," do
      it "returns false for an already confirmed swimmer" do
        UserSwimmerConfirmation.confirm_for( @user, @swimmer, @user2 )
        expect( subject.is_confirmable_by(@user) ).to be false
      end
    end
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_confirmable_by ], @user_not_associated, "an unassociated user"
    )
    context "(an unassociated user)," do
      it "returns a false for an unconfirmable swimmer (user must be a 'valid goggler' to do it)" do
        @user_not_associated.set_associated_swimmer( create(:swimmer) )
        UserSwimmerConfirmation.confirm_for( @user, @swimmer, @user_not_associated )
        # If the User-not-associated becomes unassociated again,
        # then he should not be able to de-confirm an already confirmed swimmer:
        @user_not_associated.set_associated_swimmer(nil)
        expect( subject.is_confirmable_by(@user_not_associated) ).to be false
      end
    end
  end
  # ---------------------------------------------------------------------------


  describe "#is_unconfirmable_by" do
    context "(a different user)," do
      it "returns false for an unconfirmed swimmer" do
        expect( subject.is_unconfirmable_by(@user2) ).to be false
      end
      it "returns true for an already confirmed swimmer" do
        UserSwimmerConfirmation.confirm_for( @user, @swimmer, @user2 )
        expect( subject.is_unconfirmable_by(@user2) ).to be true
      end
    end
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_unconfirmable_by ], @user, "the same user"
    )
    context "(the same current user)," do
      it "returns false for an already confirmed swimmer" do
        UserSwimmerConfirmation.confirm_for( @user, @swimmer, @user2 )
        expect( subject.is_unconfirmable_by(@user) ).to be false
      end
    end
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_unconfirmable_by ], @user_not_associated, "an unassociated user"
    )
    context "(an unassociated user)," do
      it "returns a false for an unconfirmable swimmer (user must be a 'valid goggler' to do it)" do
        @user_not_associated.set_associated_swimmer( create(:swimmer) )
        UserSwimmerConfirmation.confirm_for( @user, @swimmer, @user_not_associated )
        # If the User-not-associated becomes unassociated again,
        # then he should not be able to de-confirm an already confirmed swimmer:
        @user_not_associated.set_associated_swimmer(nil)
        expect( subject.is_unconfirmable_by(@user_not_associated) ).to be false
      end
    end
  end
  # ---------------------------------------------------------------------------


  describe "#is_invitable_by" do
    context "(a different user)," do
      it "returns true for a new friendable swimmer" do
        expect( subject.is_invitable_by(@user2) ).to be true
      end
      it "returns false for a pending invited swimmer" do
        @user2.invite( @user )
        expect( subject.is_invitable_by(@user2) ).to be false
      end
      it "returns false for an approved friend swimmer" do
        @user2.invite( @user )
        @user.approve( @user2 )
        expect( subject.is_invitable_by(@user2) ).to be false
      end
    end
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_invitable_by ], @user, "the same user"
    )
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_invitable_by ], @user_not_associated, "an unassociated user"
    )
  end
  # ---------------------------------------------------------------------------


  describe "#is_pending_for" do
    context "(a different user)," do
      it "returns false for a new friendable swimmer" do
        expect( subject.is_pending_for(@user2) ).to be false
      end
      it "returns true for a pending invited swimmer" do
        @user2.invite( @user )
        expect( subject.is_pending_for(@user2) ).to be true
      end
      it "returns false for a received pending invite from another user" do
        @user.invite( @user2 )
        expect( subject.is_pending_for(@user2) ).to be false
      end
      it "returns false for an approved friend swimmer" do
        @user.invite( @user2 )
        @user2.approve( @user )
        expect( subject.is_pending_for(@user2) ).to be false
      end
    end
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_pending_for ], @user, "the same user"
    )
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_pending_for ], @user_not_associated, "an unassociated user"
    )
  end
  # ---------------------------------------------------------------------------


  describe "#is_approvable_by" do
    context "(a different user)," do
      it "returns false for a new friendable swimmer" do
        expect( subject.is_approvable_by(@user2) ).to be false
      end
      it "returns true for a swimmer who's sent an invite" do
        @user.invite( @user2 )
        expect( subject.is_approvable_by(@user2) ).to be true
      end
      it "returns false for a swimmer who's received a pending invite" do
        @user2.invite( @user )
        expect( subject.is_approvable_by(@user2) ).to be false
      end
      it "returns false for an already approved friend swimmer" do
        @user.invite( @user2 )
        @user2.approve( @user )
        expect( subject.is_approvable_by(@user2) ).to be false
      end
    end
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_approvable_by ], @user, "the same user"
    )
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_approvable_by ], @user_not_associated, "an unassociated user"
    )
  end
  # ---------------------------------------------------------------------------


  describe "#is_blockable_by" do
    context "(a different user)," do
      it "returns false for a un-associated swimmer (non-valid goggler)" do
        expect( subject.is_blockable_by(create(:user)) ).to be false
      end
      it "returns false for a valid goggler who's not a friend yet" do
        expect( subject.is_blockable_by(@user2) ).to be false
      end
      it "returns true for a swimmer with a pending friendship" do
        @user.invite( @user2 )
        expect( subject.is_blockable_by(@user2) ).to be true
      end
      it "returns true for an approved friendship with a valid goggler" do
        @user2.invite( @user )
        @user.approve( @user2 )
        expect( subject.is_blockable_by(@user2) ).to be true
      end
    end
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_blockable_by ], @user, "the same user"
    )
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_blockable_by ], @user_not_associated, "an unassociated user"
    )
  end
  # ---------------------------------------------------------------------------


  describe "#is_unblockable_by" do
    context "(a different user)," do
      it "returns false for a un-associated swimmer (non-valid goggler)" do
        expect( subject.is_unblockable_by(create(:user)) ).to be false
      end
      it "returns false for a valid goggler who's not a friend yet" do
        expect( subject.is_unblockable_by(@user2) ).to be false
      end
      it "returns false for a swimmer with a pending friendship" do
        @user.invite( @user2 )
        expect( subject.is_unblockable_by(@user2) ).to be false
      end
      it "returns false for an approved friendship with a valid goggler" do
        @user2.invite( @user )
        @user.approve( @user2 )
        expect( subject.is_unblockable_by(@user2) ).to be false
      end
      it "returns true for the blocker of blocked friendship (with a valid goggler)" do
        @user2.invite( @user )
        @user.approve( @user2 ) # user approves
        @user2.block( @user )   # the other user changes idea
        expect( subject.is_unblockable_by(@user2) ).to be true
      end
      it "returns false for the blocked friend of blocked friendship" do
        @user2.invite( @user )
        @user.approve( @user2 ) # user approves
        @user2.block( @user )   # the other user changes idea
        expect( subject.is_unblockable_by(@user) ).to be false
      end
    end
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_unblockable_by ], @user, "the same user"
    )
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_unblockable_by ], @user_not_associated, "an unassociated user"
    )
  end
  # ---------------------------------------------------------------------------


  describe "#is_editable_by" do
    context "(a different user)," do
      it "returns false for a non-existing frienship" do
        expect( subject.is_editable_by(@user2) ).to be false
      end
      it "returns true for a pending friendship request" do
        @user2.invite( @user )
        expect( subject.is_editable_by(@user2) ).to be true
      end
      it "returns true for an approved friendship" do
        @user2.invite( @user )
        @user.approve( @user2 )
        expect( subject.is_editable_by(@user2) ).to be true
      end
    end
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_editable_by ], @user, "the same user"
    )
    it_behaves_like(
      "(an action allowed only to different users)",
      [ :is_editable_by ], @user_not_associated, "an unassociated user"
    )
  end
  # ---------------------------------------------------------------------------
end
