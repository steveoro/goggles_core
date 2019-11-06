# frozen_string_literal: true

require 'rails_helper'

describe GeocodingParser, type: :strategy do
  # Static fixture text from season 162:
  before(:all) do
    @json_fixture_1 = File.open( GogglesCore::Engine.root.join('spec', 'fixtures', 'samples', 'maps_API_geocoding_response_fixture_01.json' ) ).read
    @json_fixture_2 = File.open( GogglesCore::Engine.root.join('spec', 'fixtures', 'samples', 'maps_API_geocoding_response_fixture_02.json' ) ).read
    @json_fixture3 = File.open( GogglesCore::Engine.root.join('spec', 'fixtures', 'samples', 'maps_API_geocoding_response_fixture_03.json' ) ).read
  end

  let( :json_fixture_1_query_address )  { 'Piscina coperta del Circolo Forum Roma Sport Center, Via Cornelia n. 493 Roma (Zona Aurelio' }
  let( :json_fixture_2_query_address )  { 'Piscina di ROMAN Sport City, in via Pontina km. 30 a Pomezia' }
  let( :json_fixture3_query_address ) { 'piscina comunale, via Melato, Reggio Emilia' }
  #-- -------------------------------------------------------------------------
  #++

  context 'with valid parameters,' do
    subject { GeocodingParser.new( json_fixture3_query_address ) }

    it_behaves_like( '(the existance of a method)', [
                      :formatted_address, :location_lat, :location_lng, :place_id,
                      :status, :text_log, :json_response, :is_processed,
                      # For these, they are the "short_name" version of the returned value:
                      :street_number_name, :route_name, :locality_name, :administrative_area_level_3_name,
                      :administrative_area_level_2_name, :administrative_area_level_1_name,
                      :country_name, :postal_code_name,

                      :make_api_request, :stub_api_request, :extract_data!,
                      :get_result_dao_as_hash
                    ] )

    it_behaves_like( '(the existance of a class method)', [
                      :get_raw_web_response, :post_raw_web_request
                    ] )
    #-- -----------------------------------------------------------------------
    #++

    describe 'self.get_raw_web_response' do
      context 'for a valid & existing request URL,' do
        let(:valid_test_url)  { 'http://master-goggles.org' }
        # Some peculiar, random strings from the HTML of the page above:
        let(:expected_text_1) { '<title>Goggles</title>' }
        let(:expected_text_2) { 'alt="Breastroke"' }
        let(:expected_text_3) { 'alt="Happy bamo"' }

        subject { GeocodingParser.get_raw_web_response(valid_test_url) }

        it 'is not nil' do
          expect( subject ).not_to be( nil )
        end
        it 'responds to :body' do
          expect( subject ).to respond_to( :body )
        end
        it 'contains the expected text' do
          expect( subject.body ).to include( expected_text_1 )
          expect( subject.body ).to include( expected_text_2 )
          expect( subject.body ).to include( expected_text_3 )
        end
      end

      # ([Steve, 20170530] We do not test invalid URIs to avoid slowing down the
      #  test suite w/ the response timeout.)
    end
    #-- -----------------------------------------------------------------------
    #++

    describe 'self.post_raw_web_request' do
      context 'for an existing request URL,' do
        # Missing parameters: will do nothing and return 400-Bad request: (yet, still a not-nil, existing URL)
        let(:invalid_existing_test_url) { 'http://master-goggles.org/misc/compute_fin_score' }

        subject { GeocodingParser.post_raw_web_request(invalid_existing_test_url) }

        it 'is nil' do
          expect( subject ).to be( nil )
        end
      end

      # ([Steve, 20170530] We do not test invalid URIs to avoid slowing down the
      #  test suite w/ the response timeout.)
    end
    #-- -----------------------------------------------------------------------
    #++

    # describe "#make_api_request" do
    # context "when making a successful call," do
    # # [Steve, 20180606] Since the end of May 2018 key-less API call are no more feasible
    # # To test locally with using this spec, uncomment it and subst the text below with a correct
    # # API key
    # it "sets the #json_response member" do
    # expect{
    # subject.make_api_request(
    # # <ACTUAL_MAPS_API_KEY>
    # )
    # }.to change{ subject.json_response }
    # end
    # end
    # end
    #-- -----------------------------------------------------------------------
    #++

    describe '#stub_api_request' do
      context 'for a valid JSON text (small forged fixture #1, w/ OK status),' do
        let(:json_fixture_text) { '{ "id": "1", "status": "OK" }' }

        it 'is an Hash' do
          expect( subject.stub_api_request( json_fixture_text ) ).to be_an( Hash )
        end
        it 'has the expected JSON fields' do
          hash_result = subject.stub_api_request( json_fixture_text )
          expect( hash_result ).to have_key( 'id' )
          expect( hash_result['id'] ).to eq( '1' )
          expect( hash_result ).to have_key( 'status' )
          expect( hash_result['status'] ).to eq( 'OK' )
        end
        it "adds 'API OK' as last line of the #text_log" do
          subject.stub_api_request( json_fixture_text )
          expect( subject.text_log.split("\r\n").last ).to include( 'API OK' )
        end
        it 'resets #is_processed to false' do
          subject.stub_api_request( json_fixture_text )
          expect( subject.is_processed ).to be false
        end
      end

      context 'for a valid JSON text (small forged fixture #2, w/ NON-OK status),' do
        let(:json_fixture_text) { '{ "id": "2" }' }

        it 'is an Hash' do
          expect( subject.stub_api_request( json_fixture_text ) ).to be_an( Hash )
        end
        it 'has the expected JSON fields' do
          hash_result = subject.stub_api_request( json_fixture_text )
          expect( hash_result ).to have_key( 'id' )
          expect( hash_result['id'] ).to eq( '2' )
        end
        it "adds 'API --FAILED--' as last line of the #text_log" do
          subject.stub_api_request( json_fixture_text )
          expect( subject.text_log.split("\r\n").last ).to include( 'API --FAILED--' )
        end
        it 'resets #is_processed to false' do
          subject.stub_api_request( json_fixture_text )
          expect( subject.is_processed ).to be false
        end
      end

      shared_examples_for 'well-structured JSON Geocoding API response' do |chosen_fixture|
        it 'has the expected JSON fields' do
          # To allow member variables to be defined in current binding context,
          # we use this excamotage:
          fixtures = {
            use_fixture_1: @json_fixture_1,
            use_fixture_2: @json_fixture_2,
            use_fixture_3: @json_fixture3
          }
          hash_result = subject.stub_api_request( fixtures[chosen_fixture] )
          expect( hash_result ).to have_key( 'results' )
          expect( hash_result ).to have_key( 'status' )
          expect( hash_result['results'] ).to be_an( Array )
          expect( hash_result['results'].first ).to be_an( Hash )
          expect( hash_result['results'].first ).to have_key( 'address_components' )
          expect( hash_result['results'].first ).to have_key( 'formatted_address' )
          expect( hash_result['results'].first ).to have_key( 'geometry' )
          expect( hash_result['results'].first ).to have_key( 'place_id' )
          expect( hash_result['results'].first ).to have_key( 'types' )

          expect( hash_result['results'].first['geometry'] ).to have_key( 'location' )
          expect( hash_result['results'].first['geometry']['location'] ).to have_key( 'lat' )
          expect( hash_result['results'].first['geometry']['location'] ).to have_key( 'lng' )
        end
      end

      context 'for a valid JSON text (real case fixture #1, w/ OK status),' do
        it 'is an Hash' do
          expect( subject.stub_api_request( @json_fixture_1 ) ).to be_an( Hash )
        end

        it_behaves_like( 'well-structured JSON Geocoding API response', :use_fixture_1 )

        it 'has the expected formatted_address' do
          hash_result = subject.stub_api_request( @json_fixture_1 )
          expect(
            hash_result['results'].first['formatted_address']
          ).to eq( 'Via Cornelia, 493, 00166 Roma, Italy' )
        end
        it "adds 'API OK' as last line of the #text_log" do
          subject.stub_api_request( @json_fixture_1 )
          expect( subject.text_log.split("\r\n").last ).to include( 'API OK' )
        end
        it 'resets #is_processed to false' do
          subject.stub_api_request( @json_fixture_1 )
          expect( subject.is_processed ).to be false
        end
      end

      context 'for a valid JSON text (real case fixture #2, w/ OK status),' do
        it 'is an Hash' do
          expect( subject.stub_api_request( @json_fixture_2 ) ).to be_an( Hash )
        end

        it_behaves_like( 'well-structured JSON Geocoding API response', :use_fixture_2 )

        it 'has the expected formatted_address' do
          hash_result = subject.stub_api_request( @json_fixture_2 )
          expect(
            hash_result['results'].first['formatted_address']
          ).to eq( 'km30, Via Pontina Vecchia, 00071 Pomezia RM, Italy' )
        end
        it "adds 'API OK' as last line of the #text_log" do
          subject.stub_api_request( @json_fixture_2 )
          expect( subject.text_log.split("\r\n").last ).to include( 'API OK' )
        end
        it 'resets #is_processed to false' do
          subject.stub_api_request( @json_fixture_2 )
          expect( subject.is_processed ).to be false
        end
      end

      context 'for a valid JSON text (real case fixture #3, w/ OK status),' do
        it 'is an Hash' do
          expect( subject.stub_api_request( @json_fixture3 ) ).to be_an( Hash )
        end

        it_behaves_like( 'well-structured JSON Geocoding API response', :use_fixture_3 )

        it 'has the expected formatted_address' do
          hash_result = subject.stub_api_request( @json_fixture3 )
          expect(
            hash_result['results'].first['formatted_address']
          ).to eq( 'Via Melato, 2/D, 42122 Reggio Emilia RE, Italy' )
        end
        it "adds 'API OK' as last line of the #text_log" do
          subject.stub_api_request( @json_fixture3 )
          expect( subject.text_log.split("\r\n").last ).to include( 'API OK' )
        end
        it 'resets #is_processed to false' do
          subject.stub_api_request( @json_fixture3 )
          expect( subject.is_processed ).to be false
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#extract_data!' do
      context 'for a valid JSON text (real case fixture #1, w/ OK status),' do
        before(:each) do
          expect( @json_fixture_1 ).to be_a( String )
          subject.stub_api_request( @json_fixture_1 )
          expect( subject.json_response ).to be_an( Hash )
          subject.extract_data!
        end
        it 'sets #is_processed to true' do
          expect( subject.is_processed ).to be true
        end
        it 'sets #formatted_address w/ the expected value' do
          expect( subject.formatted_address ).to eq( 'Via Cornelia, 493, 00166 Roma, Italy' )
        end
        it 'sets #location_lat w/ the expected value' do
          expect( subject.location_lat ).to eq( 41.8901822 )
        end
        it 'sets #location_lng w/ the expected value' do
          expect( subject.location_lng ).to eq( 12.3837457 )
        end
        it 'sets #place_id w/ the expected value' do
          expect( subject.place_id ).to eq( 'ChIJy1yFXXBfLxMRWpRqfSyhc5g' )
        end
        it 'sets #street_number_name w/ the expected value' do
          expect( subject.street_number_name ).to eq( '493' )
        end
        it 'sets #route_name w/ the expected value' do
          expect( subject.route_name ).to eq( 'Via Cornelia' )
        end
        it 'sets #locality_name w/ the expected value' do
          expect( subject.locality_name ).to eq( 'Roma' )
        end
        it 'sets #administrative_area_level_3_name w/ the expected value' do
          expect( subject.administrative_area_level_3_name ).to eq( 'Roma' )
        end
        it 'sets #administrative_area_level_2_name w/ the expected value' do
          expect( subject.administrative_area_level_2_name ).to eq( 'RM' )
        end
        it 'sets #administrative_area_level_1_name w/ the expected value' do
          expect( subject.administrative_area_level_1_name ).to eq( 'Lazio' )
        end
        it 'sets #country_name w/ the expected value' do
          expect( subject.country_name ).to eq( 'IT' )
        end
        it 'sets #postal_code_name w/ the expected value' do
          expect( subject.postal_code_name ).to eq( '00166' )
        end
      end

      context 'for a valid JSON text (real case fixture #2, w/ OK status),' do
        before(:each) do
          expect( @json_fixture_2 ).to be_a( String )
          subject.stub_api_request( @json_fixture_2 )
          expect( subject.json_response ).to be_an( Hash )
          subject.extract_data!
        end
        it 'sets #is_processed to true' do
          expect( subject.is_processed ).to be true
        end
        it 'sets #formatted_address w/ the expected value' do
          expect( subject.formatted_address ).to eq( 'km30, Via Pontina Vecchia, 00071 Pomezia RM, Italy' )
        end
        it 'sets #location_lat w/ the expected value' do
          expect( subject.location_lat ).to eq( 41.674459 )
        end
        it 'sets #location_lng w/ the expected value' do
          expect( subject.location_lng ).to eq( 12.508192 )
        end
        it 'sets #place_id w/ the expected value' do
          expect( subject.place_id ).to eq( 'ChIJbVvcB0ySJRMR80H4srQcIBc' )
        end
        it 'sets #street_number_name w/ the expected value' do
          expect( subject.street_number_name ).to be nil
        end
        it 'sets #route_name w/ the expected value' do
          expect( subject.route_name ).to eq( 'Via Pontina Vecchia' )
        end
        it 'sets #locality_name w/ the expected value' do
          expect( subject.locality_name ).to eq( 'Pomezia' )
        end
        it 'sets #administrative_area_level_3_name w/ the expected value' do
          expect( subject.administrative_area_level_3_name ).to eq( 'Pomezia' )
        end
        it 'sets #administrative_area_level_2_name w/ the expected value' do
          expect( subject.administrative_area_level_2_name ).to eq( 'RM' )
        end
        it 'sets #administrative_area_level_1_name w/ the expected value' do
          expect( subject.administrative_area_level_1_name ).to be nil
        end
        it 'sets #country_name w/ the expected value' do
          expect( subject.country_name ).to eq( 'IT' )
        end
        it 'sets #postal_code_name w/ the expected value' do
          expect( subject.postal_code_name ).to eq( '00071' )
        end
      end

      context 'for a valid JSON text (real case fixture #3, w/ OK status),' do
        before(:each) do
          expect( @json_fixture3 ).to be_a( String )
          subject.stub_api_request( @json_fixture3 )
          expect( subject.json_response ).to be_an( Hash )
          subject.extract_data!
        end
        it 'sets #is_processed to true' do
          expect( subject.is_processed ).to be true
        end
        it 'sets #formatted_address w/ the expected value' do
          expect( subject.formatted_address ).to eq( 'Via Melato, 2/D, 42122 Reggio Emilia RE, Italy' )
        end
        it 'sets #location_lat w/ the expected value' do
          expect( subject.location_lat ).to eq( 44.6895684 )
        end
        it 'sets #location_lng w/ the expected value' do
          expect( subject.location_lng ).to eq( 10.6455183 )
        end
        it 'sets #place_id w/ the expected value' do
          expect( subject.place_id ).to eq( 'ChIJN-jaZqodgEcRn6dRSouzYbI' )
        end
        it 'sets #street_number_name w/ the expected value' do
          expect( subject.street_number_name ).to eq( '2/D' )
        end
        it 'sets #route_name w/ the expected value' do
          expect( subject.route_name ).to eq( 'Via Melato' )
        end
        it 'sets #locality_name w/ the expected value' do
          expect( subject.locality_name ).to eq( 'Reggio Emilia' )
        end
        it 'sets #administrative_area_level_3_name w/ the expected value' do
          expect( subject.administrative_area_level_3_name ).to eq( "Reggio nell'Emilia" )
        end
        it 'sets #administrative_area_level_2_name w/ the expected value' do
          expect( subject.administrative_area_level_2_name ).to eq( 'RE' )
        end
        it 'sets #administrative_area_level_1_name w/ the expected value' do
          expect( subject.administrative_area_level_1_name ).to eq( 'Emilia-Romagna' )
        end
        it 'sets #country_name w/ the expected value' do
          expect( subject.country_name ).to eq( 'IT' )
        end
        it 'sets #postal_code_name w/ the expected value' do
          expect( subject.postal_code_name ).to eq( '42122' )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'with invalid parameters,' do
    it 'raises an ArgumentError' do
      expect { FinCalendarTextParser.new }.to raise_error( ArgumentError )
      expect { FinCalendarTextParser.new(nil) }.to raise_error( ArgumentError )
      expect { FinCalendarTextParser.new(1) }.to raise_error( ArgumentError )
      expect { FinCalendarTextParser.new('') }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
