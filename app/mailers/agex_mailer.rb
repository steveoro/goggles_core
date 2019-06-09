# frozen_string_literal: true

require 'goggles_core/app_constants'

#
# = AgexMailer
#
#   - version:  5.00
#   - author:   Steve A.
#
#   Mailer base custom class for the Agex framework.
class AgexMailer < ActionMailer::Base

  # Internal Mailer address for the "From" field of the e-mails. Usually something like "no-reply@fasar.software.it"
  #
  default from: "AgeX Mailer <no-reply@#{GogglesCore::AppConstants::WEB_MAIN_DOMAIN_NAME}>"

  # "Exception intercepted" message.
  # Sends to one of the admins a notification e-mail about an error intercepted.
  #
  # == Params:
  #
  # - user: the current_user instance
  # - error_description: the error message or description
  # - error_backtrace: an array of string rows describing the current error backtrace
  #
  def exception_mail(user, error_description, error_backtrace)
    @admin_names = GogglesCore::AppConstants::WEB_ADMIN_EMAILS
    @user_name   = user.name if user.respond_to?(:name)
    @description = error_description
    @backtrace   = error_backtrace
    @host = GogglesCore::AppConstants::WEB_MAIN_DOMAIN_NAME

    mail(
      subject: "[#{GogglesCore::AppConstants::WEB_APP_NAME}@#{@host}] AgexMailer EXCEPTION: '#{error_description}'.",
      to: GogglesCore::AppConstants::WEB_ADMIN_EMAILS,
      date: Time.zone.now
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Action notify message.
  # Sends to one of the admins a notification e-mail about a specific
  # action carried out by a user.
  #
  # == Params:
  #
  # - user: the current_user instance
  # - action_name: the action name performed by the user
  # - action_description: a more verbose string description for the action carried out by the user
  # - attachment_file_name: when not nil, it will add a multipart mail attachment with the given name
  # - attachment_full_local_path: full local path to read the file for the attachment
  #
  def action_notify_mail(user, action_name, action_description, attachment_file_name = nil, attachment_full_local_path = nil)
    @user_name = user.name if user.respond_to?(:name)
    @action_name = action_name
    @description = action_description
    @host = GogglesCore::AppConstants::WEB_MAIN_DOMAIN_NAME
    attachments[attachment_file_name] = File.read(attachment_full_local_path) if attachment_file_name

    mail(
      subject: "[#{GogglesCore::AppConstants::WEB_APP_NAME}@#{@host}] AgexMailer '#{action_name}'",
      to: GogglesCore::AppConstants::WEB_ADMIN_EMAILS,
      date: Time.zone.now
    )
  end
  #-- -------------------------------------------------------------------------
  #++

  # Report abuse message.
  # Sends to one of the admins a notification e-mail about a possible abuse report,
  # notified by a user against another user.
  #
  # == Params:
  #
  # - user_sender: the current_user instance or the sender of the message
  # - user_involved: the user instance reported for possible abuse
  # - entity_name: name of the table or entity that has been abused by the user_involved (i.e.: 'swimming_pool_reviews')
  # - entity_id: ID of the entity row created by the user_involved (i.e., the ID of the review row reported for abuse)
  # - entity_title: title or specific value describing the entity row created by the user_involved (i.e., the title of the review)
  #
  def report_abuse_mail(user_sender, user_involved, entity_name, entity_id, entity_title)
    @user_sender   = user_sender
    @user_involved = user_involved
    @entity_name   = entity_name
    @entity_id     = entity_id
    @entity_title  = entity_title
    @host = GogglesCore::AppConstants::WEB_MAIN_DOMAIN_NAME

    mail(
      subject: "[#{GogglesCore::AppConstants::WEB_APP_NAME}@#{@host}] Abuse report for '#{entity_name}', ID:#{entity_id}",
      to: GogglesCore::AppConstants::WEB_ADMIN_EMAILS,
      date: Time.zone.now
    )
  end

end
#-- ---------------------------------------------------------------------------
#++
