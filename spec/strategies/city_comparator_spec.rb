# frozen_string_literal: true

require 'rails_helper'
require 'ffaker'

describe CityComparator, type: :strategy do
  let(:composed_city_names) do
    [
      "REGGIO NELL'EMILIA",
      'CADELBOSCO DI SOTTO',
      "CASTENUOVO NE' MONTI",
      'REGGIO CALABRIA'
    ]
  end
  let(:single_city_names) do
    %w[
      PARMA
      MODENA
      MILANO
      BOLOGNA
    ]
  end

  let(:team_names) do
    [
      'CSI Nuoto Ober Ferrari ASD',
      'CSI NUOTO CORREGGIO',
      'CSI NUOTO MASTER IMOLA',
      'FERRARI NUOTO MODENA',
      'NUOTO MASTER CSI LUGO'
    ]
  end
  let(:city_from_team_expectations) do
    [
      'Reggio Emilia,Reggio Emilia',
      'Correggio,Reggio Emilia',
      'Imola,Imola',
      'Modena,Modena',
      'Lugo,Ravenna,48022'
    ]
  end

  context 'as a stand-alone class,' do
    subject { CityComparator }

    # Since subject is already a class, we just need to use this shared existance example
    # instead of the "(the existance of a class method)":
    it_behaves_like( '(the existance of a method)', [
                      :get_token_array_from_city_member_name,
                      :compare_city_member_strings, :seems_the_same
                    ] )
    #-- -----------------------------------------------------------------------
    #++

    context 'instance methods' do
      subject { CityComparator.new }

      describe '#search_composed_name' do
        it 'returns a City instance when a match is found' do
          ambiguous_city = create( :city, name: 'Port' )
          primary_team_names = ( create_list( :city, 15 ) << ambiguous_city )
                               .map { |city| "#{city.name} Swimming Club United" }
          primary_team_names.each do |team_name|
            # DEBUG
            #            puts "Searching '#{team_name}'"
            expect( subject.search_composed_name(team_name) ).to be_an_instance_of(City)
          end
        end

        [
          'Reggio Emilia Nuoto ASD', 'Castelnovo Monti Team Club',
          'Parma Club 91', 'Modena Nuoto', 'CSI Correggio',
          'Scuola Nuoto Carpi'
        ].each do |team_name|
          it "returns a City instance when a match is found among existing seeds (team: '#{team_name}')" do
            expect( subject.search_composed_name(team_name) ).to be_an_instance_of(City)
          end
        end
        it 'returns nil when no matches are found' do
          expect( subject.search_composed_name( "Asdfgh#{ FFaker::Lorem.word.camelcase }Qwerty Team") ).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe 'self.get_token_array_from_city_member_name()' do
      it 'returns an Array of basic name tokens for a composed name' do
        composed_city_names.each_with_index do |city_name, _index|
          result = subject.get_token_array_from_city_member_name( city_name )
          # DEBUG
          #          puts "\r\n#Checking #{city_name}: #{result.inspect}"
          expect( result ).to be_an_instance_of( Array )
          expect( result.size ).to eq(2)
          expect( result ).to all( be_an_instance_of( String ) )
        end
      end
      it 'returns an Array with just the string for a simple city name' do
        single_city_names.each_with_index do |city_name, _index|
          result = subject.get_token_array_from_city_member_name( city_name )
          expect( result ).to be_an_instance_of( Array )
          expect( result.size ).to eq(1)
          expect( result.first ).to be_an_instance_of( String )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe 'self.compare_city_member_strings()' do
      it 'returns true when two city member (city, area, country) names looks the same' do
        [
          ['Reggio Emilia', "Reggio nell'Emilia"],
          ['Cadelbosco Sopra', 'Cadelbosco di Sopra'],
          ['Castelnovo Monti', "Castelnovo Ne'Monti"]
        ].each do |city_name_pair|
          name_1, name_2 = city_name_pair
          # DEBUG
          #          puts "\r\n#Checking #{name_1} vs. #{name_2}"
          expect( subject.compare_city_member_strings(name_1, name_2) ).to be true
        end
      end
      it 'returns false for two completely unrelated names' do
        [
          ['Rome', 'New York'],
          %w[Borzano Bolzano],
          %w[Parto Prato]
        ].each do |city_name_pair|
          name_1, name_2 = city_name_pair
          expect( subject.compare_city_member_strings(name_1, name_2) ).to be false
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe 'self.seems_the_same()' do
      it 'returns true when cities looks the same' do
        [
          ['Reggio Emilia',    "Reggio nell'Emilia",  'RE', 'RE', 'I', 'I'],
          ['Cadelbosco Sopra', 'Cadelbosco di Sopra', 'RE', 'RE', 'I', 'I'],
          ['Castelnovo Monti', "Castelnovo Ne'Monti", 'RE', 'RE', 'I', 'I']
        ].each do |city_member_list|
          # DEBUG
          #          puts "\r\n#Checking #{city_member_list.inspect}"
          city_1, city_2, area_1, area_2, country_1, country_2 = city_member_list
          expect( subject.seems_the_same( city_1, city_2, area_1, area_2, country_1, country_2 ) ).to be true
        end
      end
      it 'returns false for two completely unrelated cities' do
        [
          ['Reggio Calabria', 'Reggio Emilia',  'RC', 'RE', 'I', 'I'],
          ['Rome',            'New York',       'RE', 'NY', 'I', 'USA'],
          %w[Borzano Bolzano RE BZ I I],
          ['Parto', 'Prato', '??', 'SI', 'I', 'I']
        ].each do |city_name_pair|
          name_1, name_2 = city_name_pair
          expect( subject.compare_city_member_strings(name_1, name_2) ).to be false
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
