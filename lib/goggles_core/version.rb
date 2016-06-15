=begin

= Version module

  - version:  1.00.01
  - author:   Steve A.

  Semantic Versioning implementation.
=end
module GogglesCore
  #--
  # [Steve, 20080414]
  # ** DO NOT CHANGE ANY OF THE FOLLOWING UNLESS YOU KNOW WHAT YOU'RE DOING!! **
  #++

  # Framework Core internal name.
  # This is used to refer to any legacy code inherited or copied into this Application.
  # (Leave unchanged if not used.)
  CORE    = 'C6'

  # Actual Core versioning, used for Gem differentiation.
  VERSION = "0.0.3"

  # Major version.
  MAJOR   = '5'

  # Minor version.
  MINOR   = '001'

  # Current build version.
  BUILD   = '20160615'

  # Full versioning for the current release (Framework + Core).
  FULL    = "#{MAJOR}.#{MINOR}.#{BUILD} (#{CORE} v. #{VERSION})"

  # Compact versioning label for the current release.
  COMPACT = "#{MAJOR.gsub('.','')}#{MINOR}"

  # Current internal DB structure version
  # (this is independent from migrations and framework release)
  DB      = "1.16.45"
end
