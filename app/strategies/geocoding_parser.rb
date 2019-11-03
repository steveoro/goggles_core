require 'net/http'
require 'uri'

#
# = GeocodingParser
#
#   - Goggles framework vers.:  6.326
#   - author: Steve A.
#
#  Given a verbose address description, this strategy makes a request to Google Maps API
#  to decode and reformat the address in a more standardized way, returning a JSON
#  response that this class decodes in the internal fields.
#
#
#  === Sample usage:
#
#      parser = GeocodingParser.new("piscina comunale, via Melato, Reggio Emilia")
#      parser.make_api_request()
#      parser.extract_data!
#
#      # Export extracted & reformatted data from GeoCoding:
#      result_hash = parser.get_result_dao_as_hash()
#
#      # Serialize the data somewhere (typically, under `fin_calendars`.`place_import_text`):
#      fin_calendar_row.place_import_text = result_hash.to_json
#      fin_calendar_row.save!
#
class GeocodingParser

  # Fields returned by API JSON response:
  attr_reader :formatted_address, :location_lat, :location_lng, :place_id,
              :status,          # Actual "status" field value from parsed JSON
              :text_log,        # API actions/results log
              :json_response,   # Full parsed JSON response from API
              :is_processed,    # true when the JSON response has already been parsed & "extracted" into the data members
              # These are the "short_name" version of the returned value from the API call:
              :street_number_name, :route_name, :locality_name, :administrative_area_level_3_name,
              :administrative_area_level_2_name, :administrative_area_level_1_name,
              :country_name, :postal_code_name

  # Creates a new instance, given the current user that has "recorded" this batch
  # of operations.
  #
  def initialize( verbose_address_text )
    raise ArgumentError, 'The verbose_address_text must be a non-empty String.' unless verbose_address_text.instance_of?( String ) && !verbose_address_text.empty?

    @verbose_address_text = verbose_address_text
    @is_processed = false
    @text_log = ''
  end
  #-- -------------------------------------------------------------------------
  #++

  # Generic GET HTTP(S) for API endpoint.
  # No logging of this action is perfomed. (Logging should occur in the caller.)
  #
  # Returns the "raw" web response (as a Net::HTTP instance) for a specified URI
  # using the Net::HTTP library.
  # Returns nil in case of a NOT-Ok response.
  #
  # === Params:
  # @param request_url, link to the API endpoint to be called
  #
  def self.get_raw_web_response( request_url )
    uri = URI.encode_www_form(request_url) # was: URI( URI.escape(request_url) )
    res = Net::HTTP.get_response( uri )
    ( !res.is_a?( Net::HTTPSuccess ) ? nil : res )
  end

  # Generic POST HTTP(S) for API endpoint.
  # No logging of this action is perfomed. (Logging should occur in the caller.)
  #
  # Returns the "raw" web response (as a Net::HTTP instance) for a specified URI
  # using the Net::HTTP library.
  # Returns nil in case of a NOT-Ok response.
  #
  # === Params:
  # @param request_url, link to the API endpoint to be called
  #
  def self.post_raw_web_request( request_url )
    uri = URI.encode_www_form(request_url) # was: URI( URI.escape(request_url) )
    req = Net::HTTP::Post.new( uri )
    res = Net::HTTP.start( uri.host, uri.port, use_ssl: (uri.scheme == 'https') ) do |http|
      http.request( req )
    end
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      res
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Performs a single request to the GeoCoder Maps API and stores the JSON result,
  # updating both the internal members :json_result and :status.
  #
  # Requires a valid API Key to be invoked using an extended API usage plan.
  #
  def make_api_request( api_key = nil )
    if api_key.nil?
      @text_log << "Requests to Maps API cannot be key-less since the end of May 2018. Returning nil...\r\n"
      return nil
    end
    query_address_text = @verbose_address_text.gsub(/\s/, '+')
    api_endpoint = "https://maps.googleapis.com/maps/api/geocode/json?address=#{ query_address_text }+IT&key=#{ api_key }"
    @text_log << "GET '#{ api_endpoint }'...\r\n" # Log the action
    web_response = GeocodingParser.get_raw_web_response( api_endpoint )
    if web_response.nil?
      @text_log << "GET result NOT-OK!\r\n"
    else
      stub_api_request( web_response.body )
    end
  end

  # Test-only method used to stub-out the requests to the GeoCoder Maps API.
  # Works exactly like #make_api_request( api_key ), without the usage of an API Key.
  # Assumes the response as always successful.
  #
  def stub_api_request( text_response )
    @is_processed = false
    begin
      @json_response = JSON.parse( text_response )
    rescue StandardError
      @json_response = nil
    end
    # Check the response status:
    @status = @json_response ? @json_response['status'] : nil
    @text_log << if @status != 'OK'
      "GeoCoder Maps API --FAILED-- with result status '#{status}'.\r\n"
    else
      "GeoCoder Maps API OK. Valid JSON result obtained.\r\n"
    end
    @json_response
  end
  #-- -------------------------------------------------------------------------
  #++

  # Porcesses an already acquired JSON response, extracting all the needed fields
  # for the internal members.
  #
  def extract_data!
    # Make sure @json_response is a valid JSON Hash:
    if @json_response.instance_of?( Hash )
      @is_processed = true
      # Extract each interesting data field and store it into dedicated members:
      if @json_response['results'].first
        @formatted_address = @json_response['results'].first['formatted_address']
        @place_id = @json_response['results'].first['place_id']

        address_components  = @json_response['results'].first['address_components']
        @postal_code_name   = find_types_key_and_return_short_name( address_components, 'postal_code' )
        @country_name       = find_types_key_and_return_short_name( address_components, 'country' )
        @administrative_area_level_1_name = find_types_key_and_return_short_name( address_components, 'administrative_area_level_1' )
        @administrative_area_level_2_name = find_types_key_and_return_short_name( address_components, 'administrative_area_level_2' )
        @administrative_area_level_3_name = find_types_key_and_return_short_name( address_components, 'administrative_area_level_3' )
        @locality_name      = find_types_key_and_return_short_name( address_components, 'locality' )
        @route_name         = find_types_key_and_return_short_name( address_components, 'route' )
        @street_number_name = find_types_key_and_return_short_name( address_components, 'street_number' )

        geometry = @json_response['results'].first['geometry']
        @location_lat = geometry['location']['lat']
        @location_lng = geometry['location']['lng']
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  # Returns the member values.extracted from #json_response as a compactified,
  # single level Hash DAO instance.
  # Returns an empty Hash if #json_response is not an Hash.
  #
  # The resulting valid Hash has the following structure:
  #
  #     {
  #       "formatted_address" => <string value>,
  #       "location_lat" => <string value>,
  #       "location_lng" => <string value>,
  #       "place_id" => <string value>,
  #
  #       "street_number_name" => <string value>,
  #       "route_name" => <string value>,
  #       "locality_name" => <string value>,
  #       "administrative_area_level_3_name" => <string value>,
  #       "administrative_area_level_2_name" => <string value>,
  #       "administrative_area_level_1_name" => <string value>,
  #       "country_name" => <string value>,
  #       "postal_code_name" => <string value>
  #     }
  #
  # Keep in mind that some of the fields may have +nil+ values anyway.
  #
  def get_result_dao_as_hash
    # Make sure @json_response is a valid JSON Hash:
    if @json_response.instance_of?( Hash )
      {
        'formatted_address' => @formatted_address,
        'location_lat' => @location_lat,
        'location_lng' => @location_lng,
        'place_id' => @place_id,

        'street_number_name' => @street_number_name,
        'route_name' => @route_name,
        'locality_name' => @locality_name,
        'administrative_area_level_3_name' => @administrative_area_level_3_name,
        'administrative_area_level_2_name' => @administrative_area_level_2_name,
        'administrative_area_level_1_name' => @administrative_area_level_1_name,
        'country_name' => @country_name,
        'postal_code_name' => @postal_code_name
      }
    else
      {}
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  private

  # Helper method for easier navigation of the JSON response Hash.
  # Returns the (short) name value in the sub-hash, under the types_key specified.
  #
  def find_types_key_and_return_short_name( response_subhash, types_key )
    names_hash = response_subhash.find { |h| h['types'].include?( types_key ) }
    names_hash.instance_of?(Hash) ? names_hash['short_name'] : nil
  end
  #-- -------------------------------------------------------------------------
  #++

end
