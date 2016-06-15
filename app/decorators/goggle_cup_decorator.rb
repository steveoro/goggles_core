# encoding: utf-8
require 'draper'


=begin

= GoggleCupDecorator

  - version:  4.00.837
  - author:   Leega

  Decorator for the GoggleCup model.
  Contains all presentation-logic centered methods.

=end
class GoggleCupDecorator < Draper::Decorator
  delegate_all
  include Rails.application.routes.url_helpers

  # Retrieves the swimmer complete name
  # with link to swimmer radiography
  #
  def get_linked_name
    h.link_to( get_full_name, team_closed_goggle_cup_path(id: goggle_cup.id), { 'data-toggle'=>'tooltip', 'title'=>I18n.t('radiography.goggle_cup_closed_tooltip') } )
  end
  #-- -------------------------------------------------------------------------
end
