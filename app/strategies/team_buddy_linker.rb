# frozen_string_literal: true

#
# = TeamBuddyLinker
#
#   - Goggles framework vers.:  4.00.589
#   - author: Steve A.
#
#   Generic strategy/service class dedicated to link a specified user to
#   all of his/her team mates.
#
#   In order to do so:
#
#   - the @user must be a "goggler"; that is, a user with a swimmer associated
#     to it;
#
#   - the @user must be a "certified goggler" (that is, "certified" by any
#     team mate to actually be the athlete that he/she claims to be);
#
#
# === Typical usage:
#
#     TeamBuddyLinker.new( @user ).socialize_with_team_mates
#
class TeamBuddyLinker

  # These attribute getters are mainly used in specs and nothing more.
  attr_reader :user, :associated_swimmer, :associated_teams, :uniq_team_mates
  #-- -------------------------------------------------------------------------
  #++

  # Creates a new instance, storing the User instance for which this
  # strategy should be used.
  #
  def initialize(user)
    unless user.instance_of?(User) && user.swimmer
      raise ArgumentError, 'TeamBuddyLinker requires as a parameter a user instance associated to a swimmer!'
    end

    @user = user
    @associated_swimmer = user.swimmer
    @associated_teams   = user.swimmer.teams
    @uniq_team_mates    = [] # Build up the team-mates list
    @associated_teams.each do |team|
      @uniq_team_mates += team.swimmers.distinct.to_a
    end
    @uniq_team_mates.reject! { |swimmer| swimmer.id == @associated_swimmer.id }
    @uniq_team_mates.uniq!
  end
  #-- -------------------------------------------------------------------------
  #++

  # Binds the #user to all of his/her team mates, declaring them automatically
  # as "swimming buddies" with all sharing priviledges turned on.
  #
  def socialize_with_team_mates
    # For each team mate which is already a registered goggler, create an automatic
    # "whole-share" invitation together with its approval (without generating a
    # newsfeed row):
    @uniq_team_mates.each do |swimmer|
      if swimmer.associated_user
        @user.invite(swimmer.associated_user, true, true, true)
        swimmer.associated_user.approve(@user, true, true, true)
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

end
