=begin

= Version module

  - version:  1.00.001
  - author:   Steve A.

  Semantic Versioning implementation.
=end
module Version
  #--
  # [Steve, 20080414]
  # ** DO NOT CHANGE ANY OF THE FOLLOWING UNLESS YOU KNOW WHAT YOU'RE DOING!! **
  #++

  # Framework Core internal name.
  # This is used to refer to any legacy code inherited or copied into this Application.
  # (Leave unchanged if not used.)
  CORE    = 'core-six'

  # Major version.
  MAJOR   = '4.00'

  # Minor version.
  MINOR   = '879'

  # Current build version.
  BUILD   = '20160604'

  # Full versioning for the current release.
  FULL    = "#{MAJOR}.#{MINOR}.#{BUILD} (#{CORE})"

  # Compact versioning label for the current release.
  COMPACT = "#{MAJOR.gsub('.','')}#{MINOR}"

  # Current internal DB version (independent from migrations and framework release)
  DB      = "1.16.45"
end