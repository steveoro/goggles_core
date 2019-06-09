# frozen_string_literal: true

require 'goggles_core/version'

#
# = Custom (global) application constants.
#
#   - version:  5.00
#   - author:   Steve A.
#
module GogglesCore
  #--
  # [Steve, 20080414]
  # ** DO NOT CHANGE ANY OF THE FOLLOWING UNLESS YOU KNOW WHAT YOU'RE DOING!! **
  #++

  module AppConstants
    # Current Framework version
    WEB_FRAMEWORK_VERSION  = GogglesCore::Version::FULL

    # App-name, lowercase, used in shared modules or sub-projects
    WEB_APP                = 'goggles'

    # "Displayable" App-name, used in shared modules or sub-projects
    WEB_APP_NAME           = 'Goggles'

    # Main web-app domain name, lowercase, used in shared modules or sub-projects
    WEB_MAIN_DOMAIN_NAME   = (Rails.env.production? ? 'master-goggles.org' : ENV['HOSTNAME']).freeze

    # Main web-app admin email accounts, used by the internal mailer to notify critical events
    WEB_ADMIN_EMAILS       = 'steve.alloro@gmail.com'

    # Main logo image file for this App, used in shared modules or sub-projects
    WEB_APP_LOGO           = 'goggles_blue_128.png'
  end
end
