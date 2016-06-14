# encoding: utf-8

require 'singleton'


=begin

= EncodingTools

  - author: Steve A.

  Container class for encoding/conversion tools.
  Refactored from old implementation, (p) 2006-2014, FASAR Software, Italy

=== Typical usage:

    EncodingTools.force_valid_encoding( any_string )

=end
class EncodingTools
  include Singleton

  # Forces the character encoding a single string/line of text.
  #
  # This will handle file encoding & invalid char sequences using a
  # forced encoding for the specified string, returning a new UTF-8
  # string.
  #
  # === Returns:
  # The same string forcibly encoded in UTF-8.
  #
  def self.force_valid_encoding( curr_line )
    if String.method_defined?( :encode )
      return curr_line if curr_line.valid_encoding?

      if curr_line.force_encoding( "UTF-8" ).valid_encoding?
        curr_line = curr_line.force_encoding("UTF-8").rstrip

      elsif curr_line.force_encoding( "ISO-8859-1" ).valid_encoding?
        curr_line = curr_line.force_encoding("ISO-8859-1")
          .encode( "UTF-8", { invalid: :replace, undef: :replace, replace: '' } )
          .rstrip

      elsif curr_line.force_encoding( "UTF-16" ).valid_encoding?
        curr_line = curr_line.force_encoding("UTF-16")
          .encode( "UTF-8", { invalid: :replace, undef: :replace, replace: '' } )
          .rstrip
      end
    else
      ic = Iconv.new('UTF-8', 'UTF-8//IGNORE')
      curr_line = ic.iconv(curr_line)
    end
    curr_line
  end
  #-- -------------------------------------------------------------------------
  #++
end
