
#
# == FinCalendarPhase2ProgramExtractor
#
# Strategy wrapper the extraction of the text of a Meeting program directly from
# the Nokogiri HTML nodeset taken fromnthe HTML manifest of a Meeting.
#
# @author   Steve A.
# @version  6.131
#
class FinCalendarPhase2ProgramExtractor

  # Scans the node-set in search for the specified first and last key word string,
  # which will be matched with text contents using reg-exp syntax.
  #
  # If the first key-word is found, it toggles a flag and starts looking for
  # the second key-word (pratically seeking for a not-consequent sequence of keywords).
  #
  # The procedure extracts all the lines of text in between the 2 key-words.
  #
  def self.extract_from_nokogiri_nodeset( nokogiri_nodeset, first_key_word, last_key_word )
    extracted_text = nokogiri_nodeset.text.gsub(/\r\n?/ui, "\r\n")

    start_index = ( extracted_text =~ /#{ first_key_word }/ui )
    end_index   = ( extracted_text =~ /#{ last_key_word }/ui )
# DEBUG
#    puts "\r\nFinCalendarPhase2ProgramExtractor( //#{ first_key_word }/ui, //#{ last_key_word }/ui ):\r\n- range: #{ start_index } .. #{ end_index }"
    if start_index
      extracted_text[ start_index .. ( end_index ? end_index-1 : -1 ) ]
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
