require 'goggles_core/version'


=begin

= Custom (global) application constants.

  - version:  5.00
  - author:   Steve A.

=end

#--
# [Steve, 20080414]
# ** DO NOT CHANGE ANY OF THE FOLLOWING UNLESS YOU KNOW WHAT YOU'RE DOING!! **
#++

# Current Framework version
WEB_FRAMEWORK_VERSION  = GogglesCore::Version::FULL unless defined? WEB_FRAMEWORK_VERSION

# App-name, lowercase, used in shared modules or sub-projects
WEB_APP                = 'goggles' unless defined? WEB_APP

# "Displayable" App-name, used in shared modules or sub-projects
WEB_APP_NAME           = 'Goggles' unless defined? WEB_APP_NAME

# Main web-app domain name, lowercase, used in shared modules or sub-projects
WEB_MAIN_DOMAIN_NAME   = ( Rails.env.production? ? 'master-goggles.org' : ENV['HOSTNAME'] ) unless defined? WEB_MAIN_DOMAIN_NAME

# Main web-app admin email accounts, used by the internal mailer to notify critical events
WEB_ADMIN_EMAILS       = 'steve.alloro@gmail.com' unless defined? WEB_ADMIN_EMAILS

# Main logo image file for this App, used in shared modules or sub-projects
WEB_APP_LOGO           = 'goggles_blue_128.png' unless defined? WEB_APP_LOGO

# Accepted and defined locales
LOCALES = {'it' => 'it-IT', 'en' => 'en-US'}.freeze
I18n.enforce_available_locales = true
