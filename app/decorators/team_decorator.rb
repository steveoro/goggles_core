# encoding: utf-8
require 'draper'


=begin

= TeamDecorator

  - version:  4.00.420
  - author:   Leega

  Decorator for the Team model.
  Contains all presentation-logic centered methods.

=end
class TeamDecorator < Draper::Decorator
  delegate_all
  include Rails.application.routes.url_helpers

  # Retrieves the team complete name
  # with link to team radiography
  #
  def get_linked_name
    h.link_to( get_full_name, team_radio_path(id: team.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('radiography.team_radio_tab_tooltip') } )
  end
  #-- -------------------------------------------------------------------------

  # Retrieves the team complete name
  # with link to team meeting results
  #
  def get_linked_to_results_name(meeting)
    h.link_to( get_full_name, meeting_show_team_results_path(id: meeting.id, team_id: team.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('meeting.show_team_results_tooltip') } )
  end
  #-- -------------------------------------------------------------------------

  # Returns the list of season types the teams was affiliate
  #
  def get_season_type_list()
    season_types ? season_types.uniq.map{ |row| row.get_full_name }.join(', ') : I18n.t('none')
  end
  #-- --------------------------------------------------------------------------

  # Returns the formatted list of contacts
  # TODO Add the link to email address
  #
  def get_contacts()
    contacts = []
    contacts.append(contact_name) if contact_name
    contacts.append("#{I18n.t('mobile')} #{phone_mobile}") if phone_mobile
    contacts.append("#{I18n.t('phone')} #{phone_number}") if phone_number
    contacts.append("#{I18n.t('fax')} #{fax_number}") if fax_number
    contacts.append("#{I18n.t('email')} " + h.mail_to(e_mail)) if e_mail
    contacts.join(', ')
  end
  #-- --------------------------------------------------------------------------

  # Returns the complete team address with address, city, country
  #
  def get_complete_address()
    "#{address} #{city ? ' - ' + city.get_full_name + ' - ' + city.country : ''}"
  end
  #-- --------------------------------------------------------------------------

  # Returns the Team's home site if present
  #
  def get_home_site()
    home_page_url ? h.link_to( home_page_url, home_page_url, { target: "blank", 'data-toggle' => 'tooltip', title: I18n.t('team.visit_home_page') } ) : I18n.t('unknown')
  end
  #-- --------------------------------------------------------------------------

  # Returns the Team's last meeting name (and header date)
  #
  def get_first_meeting_name()
    meeting = meetings.sort_by_date(:asc).first
    meeting ? h.link_to( meeting.get_full_name, meeting_show_full_path( id: meeting.id, team_id: id ), { 'data-toggle' => 'tooltip', title: I18n.t('meeting.show_team_results_tooltip') + "\r\n(#{ meeting.get_full_name })" } ) : I18n.t('none')
  end
  #-- --------------------------------------------------------------------------

  # Returns the Team's last meeting name (and header date)
  #
  def get_last_meeting_name()
    meeting = meetings.sort_by_date(:desc).first
    meeting ? h.link_to( meeting.get_full_name, meeting_show_full_path( id: meeting.id, team_id: id ), { 'data-toggle' => 'tooltip', title: I18n.t('meeting.show_team_results_tooltip') + "\r\n(#{ meeting.get_full_name })" } ) : I18n.t('none')
  end
  #-- --------------------------------------------------------------------------

  # Returns the current goggle cup name if present
  #
  def get_current_goggle_cup_name_at( evaluation_date = Date.today )
    goggle_cup = get_current_goggle_cup_at( evaluation_date )
    goggle_cup ? goggle_cup.get_full_name : I18n.t('radiography.goggle_cup_tab')
  end
  #-- --------------------------------------------------------------------------
end
