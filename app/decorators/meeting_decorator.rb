# encoding: utf-8
require 'draper'


=begin

= MeetingDecorator

  - version:  4.00.419
  - author:   Steve A.

  Decorator for the Meeting model.
  Contains all presentation-logic centered methods.

=end
class MeetingDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers
  delegate_all


  # Returns a specific string to be used as a CSS class for this
  # meeting, according to the associated season type.
  #
  # Returns an empty string when not defined.
  #
  def get_css_class_for_season_type
    if object.season_type && object.season_type.code =~ /CSI/i
      'goggles-meeting-csi'
    elsif object.season_type && object.season_type.code =~ /FIN/i
      'goggles-meeting-fin'
    else
      ''
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns an image_tag for this meeting, according to the associated season type.
  # Returns an empty string when not defined.
  #
  def get_logo_for_season_type
    if object.season_type && object.season_type.code =~ /CSI/i
      h.image_tag( 'logo_csi.png', size: '20x16' )
    elsif object.season_type && object.season_type.code =~ /FIN/i
      h.image_tag( 'logo_fin.png', size: '40x16' )
    elsif object.season
      object.season.get_season_type
    else
      ''
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the meeting description
  # with link to meeting result show full
  #
  def get_linked_full_name
    h.link_to( get_full_name, meeting_show_full_path(id: object.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('meeting.show_results_tooltip') } )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the meeting short description
  # with link to meeting result show full
  #
  def get_linked_short_name
    h.link_to( get_short_name, meeting_show_full_path(id: object.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('meeting.show_results_tooltip') } )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the meeting shortest description
  # with link to meeting result show full
  #
  def get_linked_city_with_date
    h.link_to( "#{get_city} (#{get_meeting_date})", meeting_show_full_path(id: object.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('meeting.show_results_tooltip') } )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the meeting description
  # with link to meeting result show full
  #
  def get_linked_full_name_with_date
    h.link_to( "#{get_full_name} (#{get_meeting_date})", meeting_show_full_path(id: object.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('meeting.show_results_tooltip') } )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the meeting description
  # with link to meeting result show full
  # If results are aquired the link should be to results
  # Else if the invititation is present the link should be to invitation
  # Otherwise returns the true name
  #
  def get_linked_name( name_method = :get_short_name )
    if are_results_acquired
      linked_name = h.link_to( object.send(name_method), meeting_show_full_path(id: object.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('meeting.show_results_tooltip') } )
    else
      if has_start_list
          linked_name = h.link_to( object.send(name_method), meeting_show_start_list_path(id: object.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('meeting.start_list_tooltip') } )
      else
        if invitation
          linked_name = h.link_to( object.send(name_method), meeting_show_invitation_path(id: object.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('meeting.manifest_tooltip') } )
        else
          linked_name = object.send(name_method)
        end
      end
    end
    linked_name
  end
  #-- -------------------------------------------------------------------------
  #++

  # Computes a short session warm-up schedule in html mode
  # using a new line for each session
  #
  def get_session_warm_up_times
    object.get_session_warm_up_times('<br><br>').html_safe
  end
  # ----------------------------------------------------------------------------

  # Computes a short session begin schedule in html mode
  # using a new line for each session
  #
  def get_session_begin_times
    object.get_session_begin_times('<br><br>').html_safe
  end
  # ----------------------------------------------------------------------------

  # Computes a short session event program in html mode
  # using a new line for each session
  #
  def get_complete_events
    #object.get_complete_events.split("\r\n").map{ |e| content_tag(:p, e) }.join().html_safe
    object.get_complete_events.split("\r\n").join('<br><br>').html_safe
  end
  # ----------------------------------------------------------------------------

  # Computes a description of the swimming pool
  # with a link to the swimming pool page
  #
  def get_linked_swimming_pool( name_method = :get_verbose_name )
    object.get_swimming_pool ? object.get_swimming_pool.decorate.get_linked_name( name_method ) : '?'
  end
  # ----------------------------------------------------------------------------
end
