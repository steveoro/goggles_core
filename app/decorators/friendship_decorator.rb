# encoding: utf-8
require 'draper'


=begin

= FriendshipDecorator

  - version:  4.00.313.20140610
  - author:   Steve A.

  Decorator for the Friendship model (inherited by Amistad gem).
  Contains all presentation-logic centered methods.

=end
class FriendshipDecorator < Draper::Decorator
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def created_at
  #     helpers.content_tag :span, class: 'time' do
  #       object.created_at.strftime("%a %m/%d/%y")
  #     end
  #   end


  # Renders the sharing options for verbose display.
  def to_verbose_sharing
    "#{friend.get_full_name} #{ I18n.t('social.shares') }: " <<
    [
      ( shares_passages  ? "#{ I18n.t('social.passages') }"  : '' ),
      ( shares_trainings ? "#{ I18n.t('social.trainings') }" : '' ),
      ( shares_calendars ? "#{ I18n.t('social.calendars') }" : '' )
    ].join(', ')
  end

end
