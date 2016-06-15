# encoding: utf-8
require 'draper'


=begin

= PersonalBestCollectionDecorator

  - version:  4.00.432
  - author:   Leega

  Decorator for the RecordCollection model.
  Contains all presentation-logic centered methods.

=end

# Leega.
# TODO:
# Refactor this decorator, because is the same of RecordCollectionDecorator

class PersonalBestCollectionDecorator < Draper::Decorator
  delegate_all
  include Rails.application.routes.url_helpers

  # Returns the short list of records in the collection for HTML rendering,
  # in a standard format, assuming only the first timing of the list needs to be
  # displayed:
  #
  #     <timing>
  #
  # Note that if the collection contains different kind of individual records (for
  # different pool, event, gender and category combinations), *no distinction* will
  # be made and all records will be treated as different achievements of the same
  # result. (Thus, the single initial timing, followed by a list of athletes.)
  #
  def to_short_html_list
    key, record = first
    record ? "#{record.get_timing}".html_safe : "".html_safe
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the complete list of records in the collection for HTML rendering,
  # in a standard format, assuming only the first timing of the list needs to be
  # displayed:
  #
  #     <timing> (<meeting1>, <meeting2>, ...)
  #
  # Note that if the collection contains different kind of individual records (for
  # different pool, event, gender and category combinations), *no distinction* will
  # be made and all records will be treated as different achievements of the same
  # result. (Thus, the single initial timing, followed by a list of athletes.)
  #
  # Each enlisted meeting date is a link to the meeting in which the timing has
  # been achieved.
  #
  def to_short_meeting_html_list
    rec_timing = nil
    rec_meetings = []
    each do |key, record|
      rec_timing ||= record.get_timing
      meeting = record.meeting_individual_result.meeting if record.meeting_individual_result
      # Decorate each swimmer name with a link to the meeting #show_full action:
      rec_meetings << h.link_to_if(
          meeting,
          record.meeting_individual_result.meeting.get_scheduled_date,
          meeting_show_full_path( id: meeting.id, swimmer_id: record.swimmer_id ),
          { 'data-toggle' => 'tooltip', title: I18n.t('meeting.show_swimmer_results_tooltip') + "\r\n(#{ meeting.get_full_name })" }
      )
    end
    count > 0 ? "#{rec_timing} (#{ rec_meetings.join(', ') })".html_safe : "".html_safe
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the complete list of records in the collection for HTML rendering,
  # in a standard format, assuming only the first timing of the list needs to be
  # displayed:
  #
  #     <timing> (<athlete1>, <athlete2>, ...)
  #
  # Note that if the collection contains different kind of individual records (for
  # different pool, event, gender and category combinations), *no distinction* will
  # be made and all records will be treated as different achievements of the same
  # result. (Thus, the single initial timing, followed by a list of athletes.)
  #
  # Each enlisted athlete name is a link to the meeting in which the timing has
  # been achieved.
  #
  def to_complete_html_list
    rec_timing = nil
    rec_swimmers = []
    each do |key, record|
      rec_timing ||= record.get_timing
      meeting = record.meeting_individual_result.meeting if record.meeting_individual_result
      # Decorate each swimmer name with a link to the meeting #show_full action:
      rec_swimmers << h.link_to_if(
          meeting,
          record.swimmer.get_full_name,
          meeting_show_full_path( id: meeting.id, swimmer_id: record.swimmer_id ),
          { 'data-toggle' => 'tooltip', title: I18n.t('meeting.show_swimmer_results_tooltip') + "\r\n(#{ meeting.get_full_name })" }
      )
    end
    count > 0 ? "#{rec_timing} (#{ rec_swimmers.join(', ') })".html_safe : "".html_safe
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns the complete list of records in the collection for HTML rendering,
  # in a verbose format, assuming only the first timing of the list needs to be
  # displayed:
  #
  #     <timing> (<athlete1> - <header_date1>, <athlete2> - <header_date1>, ...)
  #
  # Note that if the collection contains different kind of individual records (for
  # different pool, event, gender and category combinations), *no distinction* will
  # be made and all records will be treated as different achievements of the same
  # result. (Thus, the single initial timing, followed by a list of athletes.)
  #
  # Each enlisted athlete name is a link to the meeting in which the timing has
  # been achieved.
  #
  def to_verbose_html_list
    rec_timing = nil
    rec_swimmers = []
    each do |key, record|
      rec_timing ||= record.get_timing
      meeting = record.meeting_individual_result.meeting if record.meeting_individual_result
      link_label = record.meeting_individual_result ? "#{record.swimmer.get_full_name} - #{meeting.header_date}" : record.swimmer.get_full_name
      # Decorate each swimmer name with a link to the meeting #show_full action:
      rec_swimmers << h.link_to_if(
          meeting,
          link_label,
          meeting_show_full_path( id: meeting.id, swimmer_id: record.swimmer_id ),
          { 'data-toggle' => 'tooltip', title: I18n.t('meeting.show_swimmer_results_tooltip') + "\r\n(#{ meeting.get_full_name })" }
      )
    end
    count > 0 ? "#{rec_timing} (#{ rec_swimmers.join(', ') })".html_safe : "".html_safe
  end
  #-- -------------------------------------------------------------------------
  #++

end
