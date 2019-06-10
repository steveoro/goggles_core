# rubocop:disable Style/FrozenStringLiteralComment

require 'rails_helper'
require 'fuzzy_string_matcher'

describe FuzzyStringMatcher, type: :strategy do
  # Internal class used for testing
  class NameContainer

    attr_accessor :name
    def initialize(name)
      @name = name
    end

  end
  #-- -------------------------------------------------------------------------
  #++

  let(:city_names) do
    [
      NameContainer.new('PARMA'),
      NameContainer.new("REGGIO NELL'EMILIA"),
      NameContainer.new('MODENA'),
      NameContainer.new('REGGIO CALABRIA'),
      NameContainer.new('BOLOGNA')
    ]
  end

  let(:team_names) do
    [
      NameContainer.new('CSI Nuoto Ober Ferrari ASD'),
      NameContainer.new('CSI NUOTO CORREGGIO'),
      NameContainer.new('CSI NUOTO MASTER IMOLA'),
      NameContainer.new('FERRARI NUOTO MODENA'),
      NameContainer.new('NUOTO MASTER CSI LUGO')
    ]
  end

  context 'as a valid instance,' do
    subject { FuzzyStringMatcher.new(city_names, :name) }

    it_behaves_like('(the existance of a method)', [:find, :collect_matches, :seek_deep_match])
    #-- -----------------------------------------------------------------------
    #++

    describe '#find' do
      context 'when scanning a list of city names,' do
        it 'returns the object from the list with the best match when successful' do
          result_row = subject.find('Reggio Emilia')
          expect(result_row).to be_an_instance_of(NameContainer)
          expect(result_row.name).to eq("REGGIO NELL'EMILIA")
        end
        it 'returns nil when a match is not found' do
          result_row = subject.find('This will fail')
          expect(result_row).to be nil
        end
      end

      context 'when scanning a list of team names,' do
        subject { FuzzyStringMatcher.new(team_names, :name) }
        [
          'CSI NUOTO OBER FERR',  'CSINuoto Ober Ferrari',
          'CSI O.Ferrari',        'C.S.I. Nuoto O FERRARI',
          'CSI Nuoto Ober Ferrari'
        ].each do |matching_string|
          it "returns the best-match object from the list searching for '#{matching_string}'" do
            result_row = subject.find(matching_string)
            expect(result_row).to be_an_instance_of(NameContainer)
            expect(result_row.name).to eq('CSI Nuoto Ober Ferrari ASD')
          end
        end

        it 'returns nil when a match is not found' do
          result_row = subject.find('Another failure', FuzzyStringMatcher::BIAS_SCORE_BEST)
          expect(result_row).to be nil
        end
      end

      context 'when scanning a list of swimmer names,' do
        subject { FuzzyStringMatcher.new(Swimmer.all, :complete_name) }
        [
          ['ORLANDINI IDO PIRALDO',      'ORLANDINI IDO PIERALDO'],
          ['ORLANDINI IDO PIER ALDO',    'ORLANDINI IDO PIERALDO'],

          # This is a mis-match due to a much different length between the correct candidate
          # and the supplied search value;
          ['ORLANDINI IDO',              'ORLANDINI EDO']

          # [Steve, 20141212] Using FuzzyStringMatcher::BIAS_SCORE_BEST is necessary to be sure of
          # the match, but this will inevitably fail due to different length:
          #          [ 'ARTEAGA HECTOR ALESSAN',     'ARTEAGA HECTOR' ]
        ].each do |matching_string, expected_string|
          it "returns the best-match object from the list searching for '#{matching_string}'" do
            result_row = subject.find(matching_string, FuzzyStringMatcher::BIAS_SCORE_BEST)
            expect(result_row).to be_an_instance_of(Swimmer)
            expect(result_row.complete_name).to eq(expected_string)
          end
        end

        it 'returns nil when a match is not found' do
          result_row = subject.find('XYZYGY GYXYZY', FuzzyStringMatcher::BIAS_SCORE_BEST)
          expect(result_row).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#collect_matches' do
      it 'returns an array of Hash when successful' do
        result = subject.collect_matches('Reggio Emilia')
        expect(result).to be_an_instance_of(Array)
        expect(result.size).to be > 0
        expect(result).to all(be_an_instance_of(Hash))
      end
      it 'returns a list of Hash having the :score and :row keys when successful' do
        result = subject.collect_matches('Reggio Emilia')
        result.each do |item|
          expect(item.key?(:score)).to be true
          expect(item.key?(:row)).to be true
        end
      end
      it 'returns as the first element in the list the best match when successful' do
        result = subject.collect_matches('Reggio Emilia')
        expect(result.first[:row]).to be_an_instance_of(NameContainer)
        expect(result.first[:row].name).to eq("REGGIO NELL'EMILIA")
      end
      it 'returns an empty array when a match is not found' do
        result = subject.collect_matches('This will fail')
        expect(result).to be_an_instance_of(Array)
        expect(result.size).to eq(0)
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe '#seek_deep_match' do
      it 'returns bias_score & result_list as an Array when successful' do
        result = subject.seek_deep_match('Reggio Emilia')
        expect(result).to be_an_instance_of(Array)
        expect(result.size).to eq(2)
        expect(result[0]).to be > 0.8
      end
      it 'returns an empty result list member when no match is found' do
        result = subject.seek_deep_match('This will fail')
        expect(result).to be_an_instance_of(Array)
        expect(result.size).to eq(2)
        expect(result[1]).to be_an_instance_of(Array)
        expect(result[1].size).to eq(0)
      end

      let(:seed_teams) { Team.all }

      [
        'CSI Nuoto Ober Ferrari ASD',
        'CSINuoto Ober Ferrari',
        'CSI Nuoto Master Ober Ferrari',
        'Nuotatori',
        'Acquatime',
        'Acqua Time',
        'Acquambiente',
        'Sport Management',
        'Albatros',
        'Albatros ASD'
      ].each do |possible_team_name|
        context 'when scanning an actual list of team names,' do
          subject { FuzzyStringMatcher.new(seed_teams, :name) }

          it 'returns bias_score & result_list as an Array when successful' do
            result = subject.seek_deep_match(possible_team_name)
            expect(result).to be_an_instance_of(Array)
            expect(result.size).to eq(2)
            # We are expecting the result bias to be inside the allowed
            # range for a successful match:
            expect(result[0]).to be > FuzzyStringMatcher::BIAS_SCORE_MIN - 0.1
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
# rubocop:enable Style/FrozenStringLiteralComment
