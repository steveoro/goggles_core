# encoding: utf-8
require 'draper'


=begin

= SwimmerDecorator

  - version:  4.00.409
  - author:   Steve A.

  Decorator for the Swimmer model.
  Contains all presentation-logic centered methods.

=end
class SwimmerDecorator < Draper::Decorator
  delegate_all
  include Rails.application.routes.url_helpers

  # Getter for the label text associated with the SocialsController's actions #confirm / #unconfirm
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Confirm has 3 states: confirmable, unconfirmable & nil (not applicable).
  #
  def get_confirm_label_text_for( another_user )
    strategy = SwimmerUserStrategy.new(object)
    if strategy.is_confirmable_by( another_user )
      I18n.t('social.menu_social_confirm')
    elsif strategy.is_unconfirmable_by( another_user )
      I18n.t('social.menu_social_unconfirm')
    else
      nil
    end
  end

  # Getter for the tooltip text associated with the SocialsController's actions #confirm / #unconfirm
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Confirm has 3 states: confirmable, unconfirmable & nil (not applicable).
  #
  def get_confirm_tooltip_text_for( another_user )
    strategy = SwimmerUserStrategy.new(object)
    if strategy.is_confirmable_by( another_user )
      I18n.t('social.confirm_request_tooltip').gsub('{USER_NAME}', object.associated_user.name).gsub('{SWIMMER_NAME}', object.get_full_name)
    elsif strategy.is_unconfirmable_by( another_user )
      I18n.t('social.unconfirm_request_tooltip').gsub('{USER_NAME}', object.associated_user.name).gsub('{SWIMMER_NAME}', object.get_full_name)
    else
      nil
    end
  end

  # Getter for the route path associated with the SocialsController's actions #confirm / #unconfirm
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Confirm has 3 states: confirmable, unconfirmable & nil (not applicable).
  #
  def get_confirm_path_for( another_user )
    strategy = SwimmerUserStrategy.new(object)
    if strategy.is_confirmable_by( another_user )
      h.social_association_confirm_path( id: object.associated_user_id )
    elsif strategy.is_unconfirmable_by( another_user )
      h.social_association_unconfirm_path( id: object.associated_user_id )
    else
      nil
    end
  end
  #-- --------------------------------------------------------------------------
  #++


  # Getter for the label text associated with the SocialsController's actions #invite / #approve
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Invite/Approve has 4 states: invitable, pending, acceptable & nil (not applicable).
  #
  def get_invite_label_text_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   if strategy.is_invitable_by( another_user )
     I18n.t('social.menu_social_invite')
   elsif strategy.is_pending_for( another_user )
     I18n.t('social.pending_invite')
   elsif strategy.is_approvable_by( another_user )
     I18n.t('social.menu_social_approve')
   else
     nil
   end
  end

  # Getter for the tooltip text associated with the SocialsController's actions #invite / #approve
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Invite/Approve has 4 states: invitable, pending, acceptable & nil (not applicable).
  #
  def get_invite_tooltip_text_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   if strategy.is_invitable_by( another_user )
     I18n.t('social.invite_request_tooltip').gsub('{SWIMMER_NAME}', object.get_full_name)
   elsif strategy.is_approvable_by( another_user )
     I18n.t('social.approve_request_tooltip').gsub('{SWIMMER_NAME}', object.get_full_name)
   else
     nil
   end
  end

  # Getter for the route path associated with the SocialsController's actions #invite / #approve
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Invite/Approve has 4 states: invitable, pending, acceptable & nil (not applicable).
  #
  def get_invite_path_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   if strategy.is_invitable_by( another_user )
     h.social_invite_path( id: object.associated_user_id )
   elsif strategy.is_approvable_by( another_user )
     h.social_approve_path( id: object.associated_user_id )
   else
     nil
   end
  end
  #-- --------------------------------------------------------------------------
  #++


  # Getter for the label text associated with the SocialsController's actions #block / #unblock
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Block/Unblock has 3 states: blockable, unblockable & nil (not applicable).
  #
  def get_block_label_text_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   if strategy.is_blockable_by( another_user )
     I18n.t('social.menu_social_block')
   elsif strategy.is_unblockable_by( another_user )
     I18n.t('social.menu_social_unblock')
   else
     nil
   end
  end

  # Getter for the tooltip text associated with the SocialsController's actions #block / #unblock
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Block/Unblock has 3 states: blockable, unblockable & nil (not applicable).
  #
  def get_block_tooltip_text_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   if strategy.is_blockable_by( another_user )
     I18n.t('social.block_request_tooltip').gsub('{SWIMMER_NAME}', object.get_full_name)
   elsif strategy.is_unblockable_by( another_user )
     I18n.t('social.unblock_request_tooltip').gsub('{SWIMMER_NAME}', object.get_full_name)
   else
     nil
   end
  end

  # Getter for the route path associated with the SocialsController's actions #block / #unblock
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Block/Unblock has 3 states: blockable, unblockable & nil (not applicable).
  #
  def get_block_path_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   if strategy.is_blockable_by( another_user )
     h.social_block_path( id: object.associated_user_id )
   elsif strategy.is_unblockable_by( another_user )
     h.social_unblock_path( id: object.associated_user_id )
   else
     nil
   end
  end
  #-- --------------------------------------------------------------------------
  #++


  # Getter for the label text associated with the SocialsController's action #remove
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Remove has 2 states: removable & nil (not applicable).
  #
  def get_remove_label_text_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   strategy.is_editable_by( another_user ) ? I18n.t('social.menu_social_remove') : nil
  end

  # Getter for the tooltip text associated with the SocialsController's action #remove
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Remove has 2 states: removable & nil (not applicable).
  #
  def get_remove_tooltip_text_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   if strategy.is_editable_by( another_user )
     I18n.t('social.remove_request_tooltip').gsub('{SWIMMER_NAME}', object.get_full_name)
   else
     nil
   end
  end

  # Getter for the route path associated with the SocialsController's action #remove
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Remove has 2 states: removable & nil (not applicable).
  #
  def get_remove_path_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   if strategy.is_editable_by( another_user )
     h.social_remove_path( id: object.associated_user_id )
   else
     nil
   end
  end
  #-- --------------------------------------------------------------------------
  #++


  # Getter for the label text associated with the SocialsController's action #edit
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Edit has 2 states: editable & nil (not applicable).
  #
  def get_edit_label_text_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   strategy.is_editable_by( another_user ) ? I18n.t('social.menu_social_edit') : nil
  end

  # Getter for the tooltip text associated with the SocialsController's action #edit
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Edit has 2 states: editable & nil (not applicable).
  #
  def get_edit_tooltip_text_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   if strategy.is_editable_by( another_user )
     I18n.t('social.edit_request_tooltip').gsub('{SWIMMER_NAME}', object.get_full_name)
   else
     nil
   end
  end

  # Getter for the route path associated with the SocialsController's action #edit
  # for the specified user (accessing this Swimmer info page).
  # Returns nil if the conditions are not met.
  #
  # Edit has 2 states: editable & nil (not applicable).
  #
  def get_edit_path_for( another_user )
   strategy = SwimmerUserStrategy.new(object)
   if strategy.is_editable_by( another_user )
     h.social_edit_path( id: swimmer.associated_user_id )
   else
     nil
   end
  end
  #-- --------------------------------------------------------------------------
  #++

  # Returns the Array of associated Teams for this Swimmer.
  #
  def get_teams()
    @teams ||= teams.uniq
  end
  #-- --------------------------------------------------------------------------

  # Returns the currently associated Teams for this Swimmer in a given season,
  # or nil if not found
  #
  def get_current_team( season )
    season_badges = badges.where( season_id: season.id )
    season_badges.last.team if season_badges.count > 0
  end
  #-- --------------------------------------------------------------------------

  # Retrieves the swimmer complete name
  # with link to swimmer radiography
  #
  def get_linked_swimmer_name
    @linked_swimmer_name ||= h.link_to( get_full_name, swimmer_radio_path(id: swimmer.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('radiography.radio_tab_tooltip') } )
  end
  #-- -------------------------------------------------------------------------

  # Retrieves the swimmer complete name
  # with link to swimmer current goggle_cup
  #
  def get_linked_swimmer_name_to_goggle_cup( goggle_cup_id = nil )
    if goggle_cup_id != nil
      @linked_swimmer_name ||= h.link_to( get_full_name, swimmer_closed_goggle_cup_path(id: swimmer.id, goggle_cup_id: goggle_cup_id ), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('radiography.goggle_cup_closed_tooltip') } )
    else
      @linked_swimmer_name ||= h.link_to( get_full_name, swimmer_current_goggle_cup_path(id: swimmer.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('radiography.goggle_cup_current_tooltip') } )
    end
  end
  #-- -------------------------------------------------------------------------

  # Retrieves a comma-separated string containing all the distinct team
  # names associated with this instance.
  #
  def get_linked_team_names
    linked_list = ""
    list = []
    if teams
      teams.uniq.each do |team|
        list.append( team.decorate.get_linked_name )
      end
      linked_list = list.join(', ')
    else
      linked_list = I18n.t('none')
    end
    linked_list
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the Array of all the MeetingIndividualResult(s) that are crowned by a
  # specific ranking position for this Swimmer.
  # If the rank is specified it will act as a filtering parameter.
  #
  def get_medals( rank_filter = [1, 2, 3] )
    MeetingIndividualResult
      .joins( :season, :event_type, :category_type, :gender_type, :pool_type )
      .is_valid
      .has_rank( rank_filter )
      .where{ swimmer_id == my{id} }
  end
  #-- --------------------------------------------------------------------------
  #++

  # Returns the total count of all the gold medals for this Swimmer.
  #
  def get_total_gold_medals()
    @swimmer_gold_medals ||= meeting_individual_results.is_valid.has_rank(1).count
  end

  # Returns the total count of all the silver medals for this Swimmer.
  #
  def get_total_silver_medals()
    @swimmer_silver_medals ||= meeting_individual_results.is_valid.has_rank(2).count
  end

  # Returns the total count of all the bronze medals for this Swimmer.
  #
  def get_total_bronze_medals()
    @swimmer_bronze_medals ||= meeting_individual_results.is_valid.has_rank(3).count
  end

  # Returns the total count of all the "wooden" medals for this Swimmer.
  #
  def get_total_wooden_medals()
    @swimmer_wooden_medals ||= meeting_individual_results.is_valid.has_rank(4).count
  end
  #-- --------------------------------------------------------------------------
  #++

  # Personal bests
  # Retrieves a personal best for the swimmer in a given event and pool types
  #
  def get_personal_best( events_by_pool_type )
    meeting_individual_results.for_event_by_pool_type(events_by_pool_type).sort_by_timing(:asc).first
  end
  #-- --------------------------------------------------------------------------
  #++
end
