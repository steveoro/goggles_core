# encoding: utf-8


=begin

= StringLogger

  - Goggles framework vers.:  4.00.825
  - author: Steve A.

  Simple/fake logger class, outputs directly any given string to the internal text
  holder method +captured+-
  Mainly used by test methods to simulate the controller +logger+ instance.

=end
class StringLogger

  attr_reader :captured

  # Initializes the internal member.
  def initialize
    @captured = ""
  end
  #-- -------------------------------------------------------------------------
  #++

  def method_missing( method_name, *args )
    @captured << "[#{ method_name.upcase }] #{ args.map{ |a| a.to_s }.join("\r\n") }"
  end
  #-- -------------------------------------------------------------------------
  #++
end
#-- ---------------------------------------------------------------------------
#++
