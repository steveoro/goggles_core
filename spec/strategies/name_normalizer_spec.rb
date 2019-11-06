# encoding: utf-8
require 'rails_helper'

#require 'name_normalizer'



describe NameNormalizer, type: :strategy do

  it_behaves_like( "(the existance of a class method)", [
    :get_meeting_code, :get_swimming_pool_nickname,
    :get_normalized_string,
    :get_normalized_name
  ] )
  #-- -------------------------------------------------------------------------
  #++


  describe "self.get_normalized_string" do
    [
      [ '',  '' ],
      [ nil,  '' ],
      [ 'Meeting Città di Gallarate',  'gallarate' ],
      [ '9° Trofeo Il Gabbiano',  'il gabbiano' ],
      [ '32° Trofeo Galluzzi',  'galluzzi' ],
      [ '6° Tr Piscine di Albaro',  'piscine di albaro' ],
      [ 'Firenze International Meeting',  'firenze international' ],
      [ '10° Trofeo Speedo DNA Nadir',  'speedo nadir' ],
      [ '15° S. Lucia delle Quaglie',  's lucia delle quaglie' ],
      [ '5° Trofeo Swim4life',  'swim4life' ],
      [ '5° tr Mayday Italia master',  'mayday italia master' ],
      [ '16 Trofeo Città di Verolanuova',  'verolanuova' ],
      [ '20° Trofeo Rovigo Nuoto',  'rovigo nuoto' ],
      [ '14° Trofeo De Akker Team ASI',  'de akker' ],
      [ '1° Meeting Olgiata 20.12',  'olgiata 2012' ],
      [ '11 Meeting Master Shark',  'master shark' ],
      [ '10° Meeting LIB SNEF',  'lib snef' ],
      [ 'Buon Natale Master 2016',  'buon natale master' ],
      [ '3° Mtng del Boccaccio', 'del boccaccio' ],
      [ '21° Trofeo ACSI Città di Gussago', 'gussago' ],
      [ '2 giorni di cloro', 'giorni di cloro' ],
      [ '6° Trofeo Città  di Pavia', 'pavia' ],
      [ '16° Trofeo Città  di Molinella', 'molinella' ]
    ].each do |source_name, expected_result|
      it "returns the expected result ('#{ source_name }' => '#{ expected_result }')" do
        expect( subject.class.get_normalized_string( source_name ) ).to eq( expected_result )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "self.get_normalized_name" do
    [
      [ '',  '' ],
      [ nil,  '' ],
      [ 'Meeting Città di Gallarate',  'gallarate' ],
      [ '9° Trofeo Il Gabbiano',  'ilgabbiano' ],
      [ '32° Trofeo Galluzzi',  'galluzzi' ],
      [ '6° Tr Piscine di Albaro',  'piscinedialbaro' ],
      [ 'Firenze International Meeting',  'firenzeinternational' ],
      [ '10° Trofeo Speedo DNA Nadir',  'speedonadir' ],
      [ '15° S. Lucia delle Quaglie',  'sluciadellequaglie' ],
      [ '5° Trofeo Swim4life',  'swim4life' ],
      [ '5° tr Mayday Italia master',  'maydayitaliamaster' ],
      [ '16 Trofeo Città di Verolanuova',  'verolanuova' ],
      [ '20° Trofeo Rovigo Nuoto',  'rovigonuoto' ],
      [ '14° Trofeo De Akker Team ASI',  'deakker' ],
      [ '1° Meeting Olgiata 20.12',  'olgiata2012' ],
      [ '11 Meeting Master Shark',  'mastershark' ],
      [ '10° Meeting LIB SNEF',  'libsnef' ],
      [ 'Buon Natale Master 2016',  'buonnatalemaster' ],
      [ '3° Mtng del Boccaccio', 'delboccaccio' ],
      [ '21° Trofeo ACSI Città di Gussago', 'gussago' ],
      [ '2 giorni di cloro', 'giornidicloro' ],
      [ '6° Trofeo Città  di Pavia', 'pavia' ],
      [ '16° Trofeo Città  di Molinella', 'molinella' ]
    ].each do |source_name, expected_result|
      it "returns the expected result ('#{ source_name }' => '#{ expected_result }')" do
        expect( subject.class.get_normalized_name( source_name ) ).to eq( expected_result )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "self.get_meeting_code" do
    [
      [ '', '',  '' ],
      [ nil, nil,  '' ],
      [ 'Meeting degli Auguri', 'livorno',  'livornodegliauguri' ],
      [ 'Meeting Città di Gallarate', 'Gallarate',  'gallarate' ],
      [ '9° Trofeo Il Gabbiano', 'Napoli',  'napoliilgabbiano' ],
      [ '10° Trofeo Aquarius Piscina Canosa', 'Canosa di Puglia',  'canosadipugliaaquariuspiscinacanosa' ],
      [ 'Campionati Regionali Emilia', 'Riccione',  'regemilia' ],
      [ 'Campionati Regionali Puglia', '-',  'regpuglia' ],
      [ 'Campionati Regionali Trentino Alto Adige', 'Rovereto',  'regtrentinoaltoadige' ],
      [ '16° Coppa Immota Manet', 'L`Aquila',  'laquilaimmotamanet' ],
      [ '21° Trofeo Forum Sprint', 'Roma',  'romaforumsprint' ],
      [ '10° Meeting LIB SNEF', 'Sondrio',  'sondriolibsnef' ],
      [ '6° Trofeo Città  di Pavia', 'Lodi', 'lodipavia' ],
      [ '16° Trofeo Città  di Molinella', 'Molinella', 'molinella' ],
      [ '32° Trofeo Galluzzi',  'Città di Castello', 'castellogalluzzi' ],

      [ "Campionato Regionale Campania - seconda sessione", "Volla - Napoli", "regcampaniasecondasessione" ],
      [ "Distanze Speciali Campania", "Napoli", "speccampania" ]
      # TODO Add more tests
    ].each do |source_title, source_city, expected_result|
      it "returns the expected result (['#{ source_title }', '#{ source_city }'] => '#{ expected_result }')" do
        expect( subject.class.get_meeting_code( source_title, source_city ) ).to eq( expected_result )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "self.get_swimming_pool_nickname()" do
    let(:city)              { City.all.sample }
    let(:city_normalized)   { NameNormalizer.get_normalized_name( city.name ) }
    let(:pool_type)         { PoolType.all.sample }

    context "for a name w/ dots in it," do
      let(:pool_name_tokens)  { ["Comunale O. Ferrari"] }
      subject { NameNormalizer.get_swimming_pool_nickname( city, pool_name_tokens, pool_type ) }
      it "includes the normalized city name in the result" do
        expect( subject ).to include( city_normalized )
      end
      it "returns the nick_name w/o dots" do
        expect( subject ).not_to include(".")
      end
      it "includes the pool type code in the result" do
        expect( subject ).to include( pool_type.code )
      end
    end

    context "for a name w/ 'centro sportivo' in it," do
      let(:pool_name_tokens)  { ["Centro Sportivo Campedelli"] }
      subject { NameNormalizer.get_swimming_pool_nickname( city, pool_name_tokens, pool_type ) }
      it "includes the normalized city name in the result" do
        expect( subject ).to include( city_normalized )
      end
      it "returns the nick_name including the string 'cs'" do
        expect( subject ).to include("cs")
      end
      it "includes the pool type code in the result" do
        expect( subject ).to include( pool_type.code )
      end
    end

    context "for a name w/ 'villaggiosportivo' in it," do
      let(:pool_name_tokens)  { ["VillaggioSportivo Gigi"] }
      subject { NameNormalizer.get_swimming_pool_nickname( city, pool_name_tokens, pool_type ) }
      it "includes the normalized city name in the result" do
        expect( subject ).to include( city_normalized )
      end
      it "returns the nick_name including the string 'vs'" do
        expect( subject ).to include("vs")
      end
      it "includes the pool type code in the result" do
        expect( subject ).to include( pool_type.code )
      end
    end

    context "for a name w/ 'sport center' in it," do
      let(:pool_name_tokens)  { ["Coperta circolo Forum Sport Center"] }
      subject { NameNormalizer.get_swimming_pool_nickname( city, pool_name_tokens, pool_type ) }
      it "includes the normalized city name in the result" do
        expect( subject ).to include( city_normalized )
      end
      it "returns the nick_name including the string 'sc'" do
        expect( subject ).to include("sc")
      end
      it "includes the pool type code in the result" do
        expect( subject ).to include( pool_type.code )
      end
    end

    context "for a name w/ 'circolo' in it," do
      let(:pool_name_tokens)  { ["Circolo Canottieri Vittorino"] }
      subject { NameNormalizer.get_swimming_pool_nickname( city, pool_name_tokens, pool_type ) }
      it "includes the normalized city name in the result" do
        expect( subject ).to include( city_normalized )
      end
      it "returns the nick_name NOT including the string 'circolo'" do
        expect( subject ).not_to include("circolo")
      end
      it "includes the pool type code in the result" do
        expect( subject ).to include( pool_type.code )
      end
    end

    context "for a name w/ the city name repeated in it," do
      let(:pool_name_tokens)  { ["Centro Sportivo #{ city.name }"] }
      subject { NameNormalizer.get_swimming_pool_nickname( city, pool_name_tokens, pool_type ) }
      it "returns the nick_name matching the normalized city name repeated twice" do
        expect( subject ).to match(/#{ city_normalized }\D+#{ city_normalized }/ui)
      end
      it "includes the pool type code in the result" do
        expect( subject ).to include( pool_type.code )
      end
    end
  end
  #-- -----------------------------------------------------------------------
  #++
end
