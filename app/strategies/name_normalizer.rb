# encoding: utf-8
require 'common/format'

=begin

= NameNormalizer

  - Goggles framework vers.:  6.127
  - author: Steve A.

 Meeting name/code normalizer strategy wrapper.

=end
class NameNormalizer

  # Returns the normalized, standard Meeting.meeting_code given the parameters.
  #
  # === Params:
  #
  # - meeting_title, the description or the title of the Meeting
  # - city_name, the city name for the Meeting
  #
  def self.get_meeting_code( meeting_title, city_name )
    if meeting_title.to_s =~ /dist(anze|\.)?\s+spec(iali|\.)?/i
      region = self.get_normalized_name( meeting_title.to_s.split(/speciali\s+/i).last )
      "spec#{ region }"
    elsif meeting_title.to_s =~ /regional.\s+/i
      region = self.get_normalized_name( meeting_title.to_s.split(/regional.\s+/i).last )
      "reg#{ region }"
    else
      norm_city = self.get_normalized_name( city_name )
      norm_title = self.get_normalized_name( meeting_title )
      # Detect the special case in which we avoid the repetition of the name:
      if norm_city == norm_title
        norm_city
      else
        "#{ norm_city }#{ norm_title }"
      end
    end
  end
  #-- --------------------------------------------------------------------------
  #++


  # Returns the swimming pool nick name given the parameters.
  # Returns "np" as default normalized pool name if the name is not given (the token
  # list is empty or nil).
  # Returns nil in case of error (either the City or the PoolType are not valid).
  #
  # @param city, an instance of City
  # @param pool_name_tokens, a list of string tokens, allegedly forming the SwimmingPool
  #        name when concatenated.
  # @param pool_type, an instance of PoolType
  #
  def self.get_swimming_pool_nickname( city, pool_name_tokens, pool_type )
    # (If the pool_name_tokens responds to :count, we can safely assume it will
    # respond to :join)
    pool_name_normalized = if pool_name_tokens && pool_name_tokens.respond_to?(:count) && (pool_name_tokens.count > 0)
      self.get_normalized_name( pool_name_tokens.join )
    else
      "comunale"
    end
    if city.instance_of?( City ) && city.name.present? && pool_type.instance_of?( PoolType )
      result = self.get_normalized_name( city.name ) + pool_name_normalized + pool_type.code
      # Make sure we won't generate nick_names longer than 40 chars:
      if result.length > 40
        result[-40..-1]
      else
        result
      end
    else
      nil
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  # Returns a normalized text by converting any UTF-8/special characters into
  # plain ASCII vowels and removing any individual punctuation characters.
  # Spaces are *NOT* affected.
  #
  # The method strips away from the name also any typical recurring prefix, like
  # "Meeting", "Trofeo", "Città di ", any ordinal numbering or year references
  # and so on.
  #
  def self.get_normalized_string( name )
    # [Steve, 20170426] We use the "non-word" char code in Regexp ("\W") because it's
    # the most generic and works even for SHIFT-SPACEs and other strange mis-typings
    # made by hand by operators (in some cases "\s" is not enough)
    name.to_s
        .gsub(/\W\d{4}/iu, '')
        .gsub(/[\-_\'`\\\/\:\.\,\;]/, '')
        .gsub(/à/iu, 'a')
        .gsub(/[èé]/iu, 'e')
        .gsub(/ì/iu, 'i')
        .gsub(/ò/iu, 'o')
        .gsub(/ù/iu, 'u')
        .gsub(/\d+°?\W/iu, '')
        .gsub(/meeting|mtng|memorial|coppa\W+|trofeo\W+|finali\W|tr\W+/iu, '')
        .gsub(/sport\W?center/ui, 'sc')
        .gsub(/villaggio\W?sportivo/ui, 'vs')
        .gsub(/centro\W?sportivo/ui, 'cs')
        .gsub(/citta\W+di\W+|circolo/iu, '')
        .gsub(/team\Wasi|acsi|snp\W|dna\W/iu, '')
        .downcase.strip
  end
  #-- --------------------------------------------------------------------------
  #++


  # "Extended" version of self.get_normalized_string() that removes also spaces.
  #
  def self.get_normalized_name( name )
    self.get_normalized_string( name ).to_s.gsub(/\W/iu, '')
  end
  #-- --------------------------------------------------------------------------
  #++
end
