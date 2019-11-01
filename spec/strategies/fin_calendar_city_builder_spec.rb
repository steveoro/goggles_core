require 'rails_helper'


describe FinCalendarCityBuilder, type: :strategy do

  context "with valid parameters," do
    subject { FinCalendarCityBuilder.new( User.find(1), "", "", false ) }

    let( :city ) { create(:city) }
    let(:record) { city }
    it_behaves_like( "SqlConverter [param: let(:record)]" )
    it_behaves_like( "SqlConvertable [subject: includee]" )


    it_behaves_like( "(the existance of a method)", [
      :report, :find_or_create!, :get_geocoder, :get_geocode_result,
      :has_updated, :has_created, :has_errors, :has_changes?
    ] )

    it_behaves_like( "(the existance of a class method)", [
      :parse_pool_city_name_tokens
    ] )
    #-- -----------------------------------------------------------------------
    #++


    describe "self.parse_pool_city_name_tokens()" do
      [
        [ "Le gare si svolgeranno presso la Piscina Olimpica Samuele di Milano, via Trani. Caratteristiche dell'impianto:", "Milano" ],
        [ "Le gare si svolgeranno presso la Piscina Comunale di Verolanuova (BS) Viale Italia 9.  Caratteristiche dell'impianto :", "Verolanuova" ],
        [ "Le gare si svolgeranno presso il Nuovo Polo Natatorio di Rovigo - Viale Porta Po, 88  Caratteristiche dell'impianto :", "Rovigo" ],
        [ "Le gare si svolgeranno presso la Piscina di Saronno,Via Cesare Miola 5, Saronno (VA).  Caratteristiche dell'impianto :", "Saronno" ],
        [ "Piscina del Polo natatorio Bruno Bianchi, Passeggio S. Andrea n. 8, Trieste", "Trieste" ],
        [ "Piscina degli Impianti Natatori Comunali di Umbertide (PG) Via Rodolfo Morandi n°6", "Umbertide" ],
        [ "Piscina del “Multieventi Sport Domus” di Serravalle, Repubblica di San Marino, Via Rancaglia 30", "Serravalle Repubblica Di San Marino" ],
        [ "Piscina “Palazzo del Nuoto” di Torino, sita in Via Filadelfia n. 89", "Torino" ],
        [ "Piscina della Canottieri Baldesio, sita in Via al Porto 3, Cremona", "Cremona" ],
        [ "Piscina del centro sportivo Zero9 sito in Roma, Via Cina n° 91 zona Torrino", "Roma" ],
        [ "Sport Center di Priolo Gargallo, sito in Via Pirandello, 13", "Priolo Gargallo" ],
        [ "Piscina“La Bastia” Via Mastacchi 188 - Livorno", "Livorno" ],
        [ "Piscine di Albaro Piazza H. Dunant 4/22 - Genova", "Genova" ],
        [ "Le gare si svolgeranno presso la Piscina comunale di L'Aquila, v.le Ovidio 3.  Caratteristiche dell'impianto :", "L'Aquila" ],
        [ "Le gare si svolgeranno presso la Piscina Comunale di Rapallo ( Impianto Ristrutturato) via S. Pietro di Novella 35 - Località Poggiolino.  Caratteristiche dell'impianto :", "Rapallo" ],
        [ "Vasca gara in accaio Inox  Profondità costante mt. 1,80 Temperatura dell'acqua: 27° - 28° C Blocchi di Partenza per Track Start Vasca per il scioglimento: ca.20 mt, senza corsie; attenzione: profondità mt.0,80 - 1,00, vasca adatta solo al scioglimento; Temperatura dell'acqua: 29°C", "" ],
        [ "Vasca coperta 25 mt, 6 corsie Cronometraggio automatico 06 dicembre - domenica  ore 08.00 : Riscaldamento ore 09.00 : 200 MI – 50 SL - 50 RA – MiStaff 4x50 SL ore 13.30 : Riscaldamento ore 14.30 : 50 FA - 50 DO – 100 SL - 100 MI", "" ],
        [ "Piscina Plaia di Catania sita in Viale Kennedy 20", "Catania" ],
        [ "Piscina piscina olimpica del Villaggio Ge-Tur, in via centrale, 29 - 33054 Lignano Sabbiadoro (UD", "Lignano Sabbiadoro" ],
        [ "Le gare si svolgeranno presso la Piscina comunale coperta G. Onesti di via Anedda, 23/B Parma – zona Moletolo.  Caratteristiche dell'impianto :", "Parma" ],
        [ "Piscina dello Stadio del Nuoto di Cuneo - Via porta Mondovì 7 Cuneo (CN", "Cuneo" ],
        [ "Piscina \"Le Gocce Franciacorta Sport Village\" 25064 GUSSAGO (Brescia) – Via Staffoli,16", "GUSSAGO Brescia" ],
        [ "Piscina Comunale di Busto Garolfo, in via Busto Arsizio snc, angolo v.le Europa", "Busto Garolfo" ],
        [ "Complesso Comunale “Piscine Olimpioniche di Nesima”, via Filippo Eredia 1", "Nesima" ],
        [ "Piscina Comunale di Cerusco di Sopra (MI), via Scappavia, 1", "Cerusco Di Sopra" ],
        [ "Piscina Comunale di Bitonto (BA), via del Petto snc - vasca 25 mt, 6 corsie", "Bitonto" ],
        [ "Piscina del Centro Sportivo Portici, sita in via De Curtis (snc) Portici (NA", "Portici" ],
        [ "Piscina del Centro Federale Pietralata, via del Tufo snc, Roma", "Roma" ],
        [ "Piscina Comunale Il Grillo, contrada San Domenico 125/A", "" ],
        [ "Piscina Comunale Sicbaldi Terramaini, via Pisano", "" ],
        [ "Piscina del C.S. Plebiscito Padova, sita in via Geremia 2/2 (laterale di Via del Plebiscito 1866", "" ],
        [ "Piscina comunale della ASD LARUS NUOTO in via Largo dei Veterani Viterbo", "" ],
        [ "Piscina di ROMAN Sport City, in via Pontina km. 30 a Pomezia", "Pomezia" ],
        [ "Le gare si svolgeranno nella nuova vasca da 50 metri della Piscina Comunale \"Carmen Longo\", (Stadio dello Sport) Bologna, Via dello Sport.  Caratteristiche dell'impianto :", "Bologna" ],
        [ "Piscina comunale, palazzetto dello sport \"Emilio Zoli\", via della Costituzione, 37 - Pontedera. In caso di maltempo la gara verrà effettuata nella vasca coperta da 25 m", "Pontedera" ],
# FIXME It may be possible to obtain city name by looking at some address specifications,
# FIXME and extract the last name as city name, as long as it is separated by either a "(" or a ",", like in the following cases:
        [ "Le gare si svolgeranno presso la Piscina del GEOVILLAGE CENTRO NUOTO - Circonvallazione Nord Direzione Golfo Aranci- OLBIA Tel. 0789 1234567.", "" ], # FIXME "OLBIA"
        [ "Piscina Piscina dell' Hotel Torre Artale, Contrada S. Onofrio, Trabia (Palermo", "" ], # FIXME "Palermo"
        [ "Piscina Comunale \"Goffredo Nannini\" (Bellariva), Lungarno Aldo Moro, Firenze", "Bellariva" ], # FIXME "Firenze"
        [ "Piscina dell' OTRE' WELLNESS CLUB sito in via Zona B39/F C.da Montedoro a Noci (BA", "C Da Montedoro A Noci" ], # FIXME "Noci"

        [ "Piscina dello \"Stadio Comunale - Carmen Longo\" - Via dello Sport a Bologna - Zona Stadio", "Bologna" ]
      ].each do |pool_text, expected_result|
        context "for the text ('#{pool_text}')," do
          it "is the expected result (#{expected_result})" do
            expect( FinCalendarCityBuilder.parse_pool_city_name_tokens(pool_text).join(' ') ).to eq(expected_result)
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#report" do
      let(:source_text_line) { "Piscine di Albaro Piazza H. Dunant 4/22 - Genova" }
      let(:meeting_place)    { "Genova" }
      subject { FinCalendarCityBuilder.new( User.find(1), source_text_line, meeting_place, false ) }

      context "right from the start," do
        it "creates a log header" do
          output = []
          expect{ subject.report( output, :<< ) }.to change{ output }
        end
        it "includes the source_text_line in the process log" do
          output = []
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to include( source_text_line )
        end
        it "includes the meeting_place in the process log" do
          output = []
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to include( meeting_place )
        end
      end

      context "after a #find_or_create! call," do
        it "reports that the specified City was found (somewhere)" do
          output = []
          subject.find_or_create!() # force_geocoding_search = false (this should skip the API call)
          # Make the end report:
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to include( "City found!" )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#find_or_create!" do
      context "when called for an existing City (w/ GeoCoding NOT forced)," do
        let(:source_text_line)  { "Piscine di Albaro Piazza H. Dunant 4/22 - Genova" }
        let(:meeting_place)     { "Genova" }
        subject                 { FinCalendarCityBuilder.new( User.find(1), source_text_line, meeting_place, false ) }
        let(:expected_city)     { City.where( "name LIKE '%#{ meeting_place }%'" ).first }

        it "sets the #result_city member to the expected City row, w/ NO changes to the DB" do
          # Let's make sure that we really have a fixture like that in the DB:
          expect( expected_city ).to be_a( City )
          subject.find_or_create!() # force_geocoding_search = false (this should skip the API call)
          expect( subject.result_city ).to be_a( City )
          expect( subject.result_city.id ).to eq( expected_city.id )
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be false
        end
      end

      context "when called for an existing City (w/ GeoCoding NOT forced, address w/ some non-ASCII chars)," do
        let(:source_text_line)  { "Acquambiente, via Cà Nove, 7/A, 35040, Sant’Urbano (PD" }
        let(:meeting_place)     { "Sant`Urbano" }
        subject                 { FinCalendarCityBuilder.new( User.find(1), source_text_line, meeting_place, false ) }
        let(:expected_city)     { City.find(155) }

        it "sets the #result_city member to the expected City row, w/ NO changes to the DB" do
          # Let's make sure that we really have a fixture like that in the DB:
          expect( expected_city ).to be_a( City )
          subject.find_or_create!() # force_geocoding_search = false (this should skip the API call)
          expect( subject.result_city ).to be_a( City )
          expect( subject.result_city.id ).to eq( expected_city.id )
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be false
        end
      end

      context "when called for a NOT-yet existing City (w/ GeoCoding NOT forced)," do
        let(:source_text_line)  { "Piscina del Circolo Tennis, Albinea, RE, 42020" }
        let(:meeting_place)     { "Albinea" }
        subject                 { FinCalendarCityBuilder.new( User.find(1), source_text_line, meeting_place, false ) }
        let(:result) do
          # Let's make sure that the fixture doesn't exist in the DB:
          expect( City.where(name: meeting_place).count ).to eq(0)
          found_city = subject.find_or_create!() # force_geocoding_search = false (this should skip the API call)
# DEBUG
          subject.find_or_create!()
          subject.report
          found_city
        end

        it "returns a City instance" do
          expect( result ).to be_a( City )
        end
        it "creates a new City with the expected new name, CHANGING the DB" do
          expect( result.name ).to eq( meeting_place )
          expect( result.id ).to be > 0
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be true
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be true
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#get_geocoder" do
      context "when called for an existing City," do
        let(:source_text_line)  { "Piscina“La Bastia” Via Mastacchi 188 - Livorno" }
        let(:meeting_place)     { "Livorno" }
        subject do
          FinCalendarCityBuilder.new( User.find(1),
            source_text_line,
            meeting_place,
            false,
            nil  # Subst w/ your correct Google Maps API key for Geocoding
          )
        end

        it "returns the internal GeocodingParser instance" do
          expect( subject.get_geocoder ).to be_a( GeocodingParser )
          # WARNING: this will make an external (and *SLOW*) API call for the GeocodingParser when the FinCalendarCityBuilder is initialized with a correct API Key!
#          expect( subject.get_geocoder.locality_name ).to eq( meeting_place )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++


  context "with invalid parameters," do
    it "raises an ArgumentError" do
      expect{ FinCalendarCityBuilder.new }.to raise_error( ArgumentError )
      expect{ FinCalendarCityBuilder.new(nil, nil, nil) }.to raise_error( ArgumentError )
      expect{ FinCalendarCityBuilder.new(nil, "", nil) }.to raise_error( ArgumentError )
      expect{ FinCalendarCityBuilder.new(nil, nil, "") }.to raise_error( ArgumentError )
      expect{ FinCalendarCityBuilder.new(1, 1, 1) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
