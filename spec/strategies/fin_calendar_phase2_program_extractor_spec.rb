# frozen_string_literal: true

require 'rails_helper'

describe FinCalendarPhase2ProgramExtractor, type: :strategy do
  it_behaves_like( '(the existance of a class method)', [
                    :extract_from_nokogiri_nodeset
                  ] )
  #-- -------------------------------------------------------------------------
  #++

  describe 'self.extract_from_nokogiri_nodeset' do
    # We need to double-escape possible ASCII codes otherwise chars like "\b" or "\@"
    # gets converted to their octal counterpart during the String/to_regexp conversion:
    let(:first_key_word)        { '\\bimpiant.\\b|\\borganizzazione\\b' }
    let(:last_key_word)         { '(\\binfo(rmazioni)?|accredito|logistic.)(?!\\@)' }

    context "when given fixture file 'man20131123innsbruckmastershark'," do
      let(:html_doc) do
        File.open( GogglesCore::Engine.root.join('spec', 'fixtures', 'samples', 'man20131123innsbruckmastershark.html') ).read
      end
      let(:nokogiri_nodeset) { Nokogiri::HTML( html_doc ).css('#content') }

      it 'returns a non-empty program text' do
        result = FinCalendarPhase2ProgramExtractor.extract_from_nokogiri_nodeset(
          nokogiri_nodeset,
          first_key_word,
          last_key_word
        )
        # DEBUG
        #        puts "\r\nresult:\r\n------------8<------------\r\n#{ result }\r\n------------8<------------"
        expect( result ).to be_present
      end
    end

    context "when given fixture file 'man20140201reglazio'," do
      let(:html_doc) do
        File.open( GogglesCore::Engine.root.join('spec', 'fixtures', 'samples', 'man20140201reglazio.html') ).read
      end
      let(:nokogiri_nodeset) { Nokogiri::HTML( html_doc ).css('#content') }

      it 'returns a non-empty program text' do
        result = FinCalendarPhase2ProgramExtractor.extract_from_nokogiri_nodeset(
          nokogiri_nodeset,
          first_key_word,
          last_key_word
        )
        # DEBUG
        #        puts "\r\nresult:\r\n------------8<------------\r\n#{ result }\r\n------------8<------------"
        expect( result ).to be_present
      end
    end

    context "when given fixture file 'man20150214regcampania'," do
      let(:html_doc) do
        File.open( GogglesCore::Engine.root.join('spec', 'fixtures', 'samples', 'man20150214regcampania.html') ).read
      end
      let(:nokogiri_nodeset) { Nokogiri::HTML( html_doc ).css('#content') }

      it 'returns a non-empty program text' do
        result = FinCalendarPhase2ProgramExtractor.extract_from_nokogiri_nodeset(
          nokogiri_nodeset,
          first_key_word,
          last_key_word
        )
        # DEBUG
        #        puts "\r\nresult:\r\n------------8<------------\r\n#{ result }\r\n------------8<------------"
        expect( result ).to be_present
      end
    end

    context "when given fixture file 'man20160207regpuglia'," do
      let(:html_doc) do
        File.open( GogglesCore::Engine.root.join('spec', 'fixtures', 'samples', 'man20160207regpuglia.html') ).read
      end
      let(:nokogiri_nodeset) { Nokogiri::HTML( html_doc ).css('#content') }

      it 'returns a non-empty program text' do
        result = FinCalendarPhase2ProgramExtractor.extract_from_nokogiri_nodeset(
          nokogiri_nodeset,
          first_key_word,
          last_key_word
        )
        # DEBUG
        #        puts "\r\nresult:\r\n------------8<------------\r\n#{ result }\r\n------------8<------------"
        expect( result ).to be_present
      end
    end

    context "when given fixture file 'man20160220regcampania'," do
      let(:html_doc) do
        File.open( GogglesCore::Engine.root.join('spec', 'fixtures', 'samples', 'man20160220regcampania.html') ).read
      end
      let(:nokogiri_nodeset) { Nokogiri::HTML( html_doc ).css('#content') }

      it 'returns a non-empty program text' do
        result = FinCalendarPhase2ProgramExtractor.extract_from_nokogiri_nodeset(
          nokogiri_nodeset,
          first_key_word,
          last_key_word
        )
        # DEBUG
        #        puts "\r\nresult:\r\n------------8<------------\r\n#{ result }\r\n------------8<------------"
        expect( result ).to be_present
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
