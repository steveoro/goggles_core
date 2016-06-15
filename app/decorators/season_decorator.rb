# encoding: utf-8
require 'draper'


=begin

= SeasonDecorator

  - version:  4.00.470
  - author:   Leega

  Decorator for the Season model.
  Contains all presentation-logic centered methods.

=end
class SeasonDecorator < Draper::Decorator
  include Rails.application.routes.url_helpers
  delegate_all


  # Retrieves the season header year
  # with link to season ranking
  #
  def get_linked_header_year
    h.link_to( header_year, championships_ranking_regional_er_csi_path(id: object.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('championships.show_full_season') } )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Retrieves the season header year
  # with link to season ranking
  #
  def get_linked_full_name
    h.link_to( get_full_name, championships_ranking_regional_er_csi_path(id: object.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('championships.show_full_season') } )
  end
  #-- -------------------------------------------------------------------------
  #++
end
