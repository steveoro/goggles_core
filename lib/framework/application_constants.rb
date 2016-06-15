=begin

= Custom (global) application constants.

  - version:  1.00.001
  - author:   Steve A.

=end

#--
# [Steve, 20080414]
# ** DO NOT CHANGE ANY OF THE FOLLOWING UNLESS YOU KNOW WHAT YOU'RE DOING!! **
#++

# Current Framework version
WEB_FRAMEWORK_VERSION  = Version::FULL unless defined? WEB_FRAMEWORK_VERSION

# App-name, lowercase, used in shared modules or sub-projects
WEB_APP                = 'goggles' unless defined? WEB_APP

# "Displayable" App-name, used in shared modules or sub-projects
WEB_APP_NAME           = 'Goggles' unless defined? WEB_APP_NAME

# Main logo image file for this App, used in shared modules or sub-projects
WEB_APP_LOGO           = 'goggles_blue_128.png' unless defined? WEB_APP_LOGO

# Accepted and defined locales
LOCALES = {'it' => 'it-IT', 'en' => 'en-US'}.freeze
I18n.enforce_available_locales = true
