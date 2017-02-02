require 'rails_helper'


describe User, :type => :model do
  it_behaves_like "DropDownListable"

  context "[a well formed instance]" do
    subject { create(:user) }

    it "is a valid istance" do
      expect( subject ).to be_valid
    end

    context "[general methods]" do
      it_behaves_like( "(the existance of a method)", [
        :get_full_name,
        :to_s,
        :get_first_and_last_name,
        :get_preferred_swimmer_level_id,
        :get_swimmer_level_type,
        :set_associated_swimmer,
        :has_associated_swimmer?,
        :has_swimmer_confirmations?,
        :find_any_confirmation_given_to
      ])
    end

    # Filtering scopes:
    it_behaves_like( "(the existance of a scope with no parameters)", [
      :data_updates_newsletter_readers,
      :achievements_newsletter_readers,
      :generic_newsletter_readers,
      :community_newsletter_readers
    ])
    #-- -----------------------------------------------------------------------
    #++

    describe "#get_first_and_last_name" do
      it "returns an array with 2 elements" do
        result = subject.get_first_and_last_name
        expect( result ).to be_an_instance_of( Array )
        expect( result.size ).to eq(2)
      end
      it "returns names extracted from the description" do
        result = subject.get_first_and_last_name
        expect( Regexp.new(result[0]) ).to match( subject.description )
        expect( Regexp.new(result[1]) ).to match( subject.description )
      end
      it "returns names extracted from the dedicated fields, when present" do
        subject.first_name = FFaker::Name.first_name
        subject.last_name  = FFaker::Name.last_name
        result = subject.get_first_and_last_name
        expect( Regexp.new(result[0]) ).to match( subject.first_name )
        expect( Regexp.new(result[1]) ).to match( subject.last_name )
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#set_associated_swimmer" do
      it "is truthy when invoked successfully" do
        swimmer = create(:swimmer)
        expect( subject.set_associated_swimmer(swimmer) ).to be_truthy
      end

      it "updates both the user and the swimmer with the corresponding (new) IDs when invoked successfully (if both are available for association)" do
        swimmer = create(:swimmer)
        subject.set_associated_swimmer(swimmer)
        expect( subject.swimmer_id ).to eq( swimmer.id )
        expect( swimmer.associated_user_id ).to eq( subject.id )
      end

      it "is falsey when invoked for an already associated swimmer" do
        swimmer = create(:swimmer)
        another_user = create(:user)
        another_user.set_associated_swimmer(swimmer)
        expect( subject.set_associated_swimmer(swimmer) ).to be_falsey
      end

      it "does nothing when invoked for an already associated swimmer" do
        swimmer = create(:swimmer)
        another_user = create(:user)
        another_user.set_associated_swimmer(swimmer)
        subject.set_associated_swimmer(swimmer)
        expect( subject.swimmer ).to be_nil
        expect( another_user.swimmer_id ).to eq( swimmer.id )
        expect( swimmer.associated_user_id ).to eq( another_user.id )
      end

      it "returns true when called with nil on an already associated user" do
        subject.set_associated_swimmer(create(:swimmer))
        expect( subject.set_associated_swimmer() ).to be_truthy
      end

      it "clears both the user and the swimmer when called with nil on an already associated user" do
        swimmer = create(:swimmer)
        subject.set_associated_swimmer(swimmer)
        expect( subject.set_associated_swimmer() ).to be_truthy
        subject.reload
        swimmer.reload
        expect( subject.swimmer_id ).to be_nil
        expect( swimmer.associated_user_id ).to be_nil
      end

      it "returns true when called with a new-swimmer for association and the user already associated to an old-swimmer" do
        old_swimmer = create(:swimmer)
        subject.set_associated_swimmer(old_swimmer)
        new_swimmer = create(:swimmer)
        expect( subject.set_associated_swimmer(new_swimmer) ).to be_truthy
      end

      it "updates correctly the user, an old-swimmer and a new-swimmer when called with a new-swimmer for association and the user already associated to an old-swimmer" do
        old_swimmer = create(:swimmer)
        subject.set_associated_swimmer(old_swimmer)
        new_swimmer = create(:swimmer)
        subject.set_associated_swimmer(new_swimmer)
        old_swimmer.reload
        subject.reload
        new_swimmer.reload
        expect( old_swimmer.associated_user_id ).to be_nil
        expect( subject.swimmer_id ).to eq( new_swimmer.id )
        expect( new_swimmer.associated_user_id ).to eq( subject.id )
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#has_associated_swimmer?" do
      it "returns true if it has an associated swimmer" do
        subject.swimmer = create(:swimmer)
        expect( subject.has_associated_swimmer? ).to be true
      end

      it "returns false if it has not an associated swimmer" do
        subject.swimmer = nil
        expect( subject.has_associated_swimmer? ).to be false
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#has_swimmer_confirmations?" do
      it "returns true if the association is confirmed" do
        confirmation = create( :user_swimmer_confirmation )
        user = confirmation.user
        expect( user.has_swimmer_confirmations? ).to be true
      end

      it "returns false if the association is not confirmed" do
        subject.swimmer = create(:swimmer)
        expect( subject.has_swimmer_confirmations? ).to be false
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#find_any_confirmation_given_to" do
      it "returns nil when no confirmations are found" do
        another_user = create(:user)
        expect( subject.find_any_confirmation_given_to(another_user) ).to be_nil
      end

      it "returns the first confirmation row found for a user" do
        confirmation = create( :user_swimmer_confirmation, confirmator: subject )
        expect( subject.find_any_confirmation_given_to(confirmation.user) ).to be_an_instance_of( UserSwimmerConfirmation )
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#given_confirmations" do
      it "enlists all the confirmations given by the user" do
        confirmation1 = create( :user_swimmer_confirmation, confirmator: subject )
        confirmation2 = create( :user_swimmer_confirmation, confirmator: subject )
        confirmation3 = create( :user_swimmer_confirmation, confirmator: subject )
        expect( subject.given_confirmations.size == 3 ).to be true
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#find_team_affiliation_id_from_team_managers_for" do
      let(:random_season) { Season.all.sort{0.5 - rand}.first }
      let(:random_team_manager) { TeamManager.all.sort{0.5 - rand}.first }

      it "returns nil when no team_managers are associated to the user" do
        expect( create(:user).find_team_affiliation_id_from_team_managers_for(random_season.id) ).to be_nil
      end

      it "returns the nil when the user/team_manager DOES NOT match the season" do
        fixture_team_manager = create(:team_manager)
        expect(
          fixture_team_manager.user.find_team_affiliation_id_from_team_managers_for( fixture_team_manager.team_affiliation.season_id + Season.count + 1 )
        ).to be nil
      end

      it "returns the FIRST team_affiliation.id for the specified season/team_manager touple when the user/team_manager matches the season" do
        # Get the season_id associated to the random team manager:
        rnd_season_id_from_tm = random_team_manager.team_affiliation.season_id
        # Get the first TA found for the selected random user for the random team manager
        # (It may be more than 1 for users managing more than 1 team)
        first_ta_id_found = random_team_manager.user.team_managers
            .includes(:team_affiliation).joins(:team_affiliation)
            .select{|tm| tm.team_affiliation.season_id == rnd_season_id_from_tm }
            .first
            .team_affiliation_id
        # Check the expectation:
        expect(
          random_team_manager.user.find_team_affiliation_id_from_team_managers_for( rnd_season_id_from_tm )
        ).to eq( first_ta_id_found )
      end
    end


    describe "#find_team_affiliation_id_from_badges_for" do
      let(:random_season)             { Season.all.sort{0.5 - rand}.first }
      let(:random_user_with_swimmer) { User.includes(:swimmer).joins(:swimmer).all.sort{0.5 - rand}.first }

      it "returns nil when no swimmers are associated to the user" do
        expect(
          create(:user, swimmer_id: nil).find_team_affiliation_id_from_badges_for(random_season.id)
        ).to be_nil
      end

      it "returns the nil when the user/team_manager DOES NOT match the season" do
        fixture_team_affiliation = random_user_with_swimmer.swimmer.badges.last.team_affiliation
        expect(
          random_user_with_swimmer.find_team_affiliation_id_from_badges_for( fixture_team_affiliation.season_id + Season.count + 1 )
        ).to be nil
      end

      it "returns the FIRST team_affiliation.id for the specified season/team_manager touple when the user/team_manager matches the season" do
        fixture_team_affiliation = random_user_with_swimmer.swimmer.badges.first.team_affiliation
        expect(
          random_user_with_swimmer.find_team_affiliation_id_from_badges_for( fixture_team_affiliation.season_id )
        ).to eq( fixture_team_affiliation.id )
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
