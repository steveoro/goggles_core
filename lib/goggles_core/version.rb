=begin

= Version module

  - version:  6.00
  - author:   Steve A.

  Semantic Versioning implementation.
=end
module GogglesCore
  #--
  # [Steve, 20080414]
  # ** DO NOT CHANGE ANY OF THE FOLLOWING UNLESS YOU KNOW WHAT YOU'RE DOING!! **
  #++

  # Actual Core versioning, used for Gem differentiation.
  VERSION = "1.1.1"

  module Version
    # Framework Core internal name.
    # This is used to refer to any legacy code inherited or copied into this Application.
    # (Leave unchanged if not used.)
    CORE    = 'C6'

    # Major version.
    MAJOR   = '6'

    # Minor version.
    MINOR   = '001'

    # Current build version.
    BUILD   = '20160927'

    # Full versioning for the current release (Framework + Core).
    FULL    = "#{MAJOR}.#{MINOR}.#{BUILD} (#{CORE} v. #{VERSION})"

    # Compact versioning label for the current release.
    COMPACT = "#{MAJOR.gsub('.','')}#{MINOR}"

    # Current internal DB structure version
    # (this is independent from migrations and framework release)
    DB      = "1.17.00"
  end
end
