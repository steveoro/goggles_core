require 'rails_helper'
require 'ffaker'


describe FinCalendarSwimmingPoolBuilder, type: :strategy do

  context "with valid parameters," do
    let(:day_token)           { (rand * 31 + 1).to_s }
    let(:month_token)         { I18n.t("date.month_names")[rand * 13 + 1] }
    let(:session_order)       { rand * 6 + 1 }
    let(:source_text_line)    { "" }
    let(:parse_result_dao) do
      dao = FinCalendarParseResultDAO.new(day_token, month_token, session_order, source_text_line)
      dao.meeting_place = FFaker::Address.city
      dao
    end
    subject { FinCalendarSwimmingPoolBuilder.new( User.find(1), parse_result_dao, parse_result_dao.source_text_line, false ) }

    let( :fin_calendar_row )  { create(:swimming_pool) }
    let(:record) { fin_calendar_row }
    it_behaves_like( "SqlConverter [param: let(:record)]" )
    it_behaves_like( "SqlConvertable [subject: includee]" )


    it_behaves_like( "(the existance of a method)", [
      :report, :find_or_create!, :result_swimming_pool, :city_builder,
      :has_updated, :has_created, :has_errors, :has_changes?
    ] )

    it_behaves_like( "(the existance of a class method)", [
      :parse_pool_name_tokens, :parse_pool_address_tokens,
      :has_different_values?
    ] )
    #-- -----------------------------------------------------------------------
    #++


    describe "self.parse_pool_name_tokens()" do
      [
        [ "Le gare si svolgeranno presso la Piscina piscina di Casale Monferrato denominata Centro Nuoto Casale Caratteristiche dell'impianto :", "Centro Nuoto Casale" ],
        [ "Le gare si svolgeranno presso la Piscina Olimpica Samuele di Milano, via Trani. Caratteristiche dell'impianto:", "Olimpica Samuele" ],
        [ "Le gare si svolgeranno presso la Piscina Comunale di Verolanuova (BS) Viale Italia 9.  Caratteristiche dell'impianto :", "Comunale" ],
        [ "Le gare si svolgeranno presso il Nuovo Polo Natatorio di Rovigo - Viale Porta Po, 88  Caratteristiche dell'impianto :", "Nuovo Polo Natatorio" ],
        [ "Le gare si svolgeranno nella nuova vasca da 50 metri della Piscina Comunale \"Carmen Longo\", (Stadio Comunale) Bologna, Via dello Sport.  Caratteristiche dell'impianto :", "Comunale Carmen Longo" ],
        [ "Piscina \"Le Gocce Franciacorta Sport Village\" 25064 GUSSAGO (Brescia) – Via Staffoli,16", "Le Gocce Franciacorta Sport Village" ],
        [ "Piscina Comunale \"Goffredo Nannini\" (Bellariva), Lungarno Aldo Moro, Firenze", "Comunale Goffredo Nannini" ],
        [ "Piscina del Polo natatorio Bruno Bianchi, Passeggio S. Andrea n. 8, Trieste", "Polo natatorio Bruno Bianchi" ],
        [ "Piscina del Centro Sportivo Portici, sita in via De Curtis (snc) Portici (NA", "Centro Sportivo Portici" ],
        [ "Piscina “Palazzo del Nuoto” di Torino, sita in Via Filadelfia n. 89", "Palazzo Nuoto" ],
        [ "Piscina degli Impianti Natatori Comunali di Umbertide (PG) Via Rodolfo Morandi n°6", "Impianti Natatori Comunali" ],
        [ "Piscina del “Multieventi Sport Domus” di Serravalle, Repubblica di San Marino, Via Rancaglia 30", "Multieventi Sport Domus" ],
        [ "Piscina della Canottieri Baldesio, sita in Via al Porto 3, Cremona", "Canottieri Baldesio" ],
        [ "Piscina dell' OTRE' WELLNESS CLUB sito in via Zona B39/F C.da Montedoro a Noci (BA", "OTRE' WELLNESS CLUB" ],
        [ "Piscina del centro sportivo Zero9 sito in Roma, Via Cina n° 91 zona Torrino", "centro sportivo Zero9" ],
        [ "Piscina del Centro Federale Pietralata, via del Tufo snc, Roma", "Centro Federale Pietralata" ],
        [ "Piscina Comunale di Busto Garolfo, in via Busto Arsizio snc, angolo v.le Europa", "Comunale" ],
        [ "Sport Center di Priolo Gargallo, sito in Via Pirandello, 13", "Sport Center" ],
        [ "Piscina Comunale Il Grillo, contrada San Domenico 125/A", "Comunale Il Grillo" ],
        [ "Piscina Comunale Sicbaldi Terramaini, via Pisano", "Comunale Sicbaldi Terramaini" ],
        [ "Piscina del C.S. Plebiscito Padova, sita in via Geremia 2/2 (laterale di Via del Plebiscito 1866", "Centro Sportivo Plebiscito Padova" ],
        [ "Piscina dello \"Stadio Comunale - Carmen Longo\" - Via dello Sport a Bologna - Zona Stadio", "Stadio Comunale Carmen Longo" ],
        [ "Piscina di ROMAN Sport City, in via Pontina km. 30 a Pomezia", "ROMAN Sport City" ],
        [ "Le gare si svolgeranno presso la Piscina di Saronno,Via Cesare Miola 5, Saronno (VA).  Caratteristiche dell'impianto :", "Saronno" ],
        [ "Complesso Comunale “Piscine Olimpioniche di Nesima”, via Filippo Eredia 1", "Comunale Piscine Olimpioniche" ],
        [ "Piscina comunale, palazzetto dello sport \"Emilio Zoli\", via della Costituzione, 37 - Pontedera. In caso di maltempo la gara verrà effettuata nella vasca coperta da 25 m", "comunale palazzetto sport Emilio Zoli" ],
        [ "Piscine di Albaro Piazza H. Dunant 4/22 - Genova", "Albaro" ],
        [ "Piscina dello Stadio del Nuoto di Cuneo - Via porta Mondovì 7 Cuneo (CN", "Stadio Nuoto" ],
        [ "Piscina piscina olimpica del Villaggio Ge-Tur, in via centrale, 29 - 33054 Lignano Sabbiadoro (UD", "olimpica Villaggio Ge Tur" ],
        [ "Piscina comunale della ASD LARUS NUOTO in via Largo dei Veterani Viterbo", "comunale ASD LARUS NUOTO" ],
        [ "Piscina Piscina dell' Hotel Torre Artale, Contrada S. Onofrio, Trabia (Palermo", "Hotel Torre Artale" ],
        [ "Piscina“La Bastia” Via Mastacchi 188 - Livorno", "La Bastia" ],
        [ "Piscina Plaia di Catania sita in Viale Kennedy 20", "Plaia" ],       # FIXME? "Plaia di Catania"
        [ "Le gare si svolgeranno presso la Piscina del GEOVILLAGE CENTRO NUOTO - Circonvallazione Nord Direzione Golfo Aranci- OLBIA Tel. 0789 1234567.", "GEOVILLAGE CENTRO NUOTO" ],
        [ "Piscina coperta del Circolo Forum Roma Sport Center, Via Cornelia n. 493 Roma (Zona Aurelio", "coperta Circolo Forum Roma Sport Center" ],
        [ "Vasca coperta 25 mt, 6 corsie\r\n\r\nCronometraggio automatico\r\n\r\n06 dicembre - domenica", "" ]
      ].each do |pool_text, expected_result|
        context "for the text ('#{pool_text}')," do
          it "is the expected result (#{expected_result})" do
            expect( FinCalendarSwimmingPoolBuilder.parse_pool_name_tokens(pool_text).join(' ') ).to eq(expected_result)
          end
        end
      end
    end


    describe "self.parse_pool_address_tokens()" do
      [
        [ "Le gare si svolgeranno presso la Piscina piscina di Casale Monferrato denominata Centro Nuoto Casale Caratteristiche dell'impianto :", "" ],
        [ "Piscina del centro sportivo Zero9 sito in Roma, Via Cina n° 91 zona Torrino", "Via Cina, n° 91" ],
        [ "Le gare si svolgeranno presso la Piscina Olimpica Samuele di Milano, via Trani. Caratteristiche dell'impianto:", "via Trani" ],
        [ "Le gare si svolgeranno presso la Piscina Comunale di Verolanuova (BS) Viale Italia 9.  Caratteristiche dell'impianto :", "Viale Italia, 9" ],
        [ "Le gare si svolgeranno presso il Nuovo Polo Natatorio di Rovigo - Viale Porta Po, 88  Caratteristiche dell'impianto :", "Viale Porta Po, 88" ],
        [ "Le gare si svolgeranno presso la Piscina di Saronno,Via Cesare Miola 5, Saronno (VA).  Caratteristiche dell'impianto :", "Via Cesare Miola, 5" ],
        [ "Le gare si svolgeranno nella nuova vasca da 50 metri della Piscina Comunale \"Carmen Longo\", (Stadio Comunale) Bologna, Via dello Sport.  Caratteristiche dell'impianto :", "Via dello Sport" ],
        [ "Piscina \"Le Gocce Franciacorta Sport Village\" 25064 GUSSAGO (Brescia) – Via Staffoli,16", "Via Staffoli, 16" ],
        [ "Piscina Comunale \"Goffredo Nannini\" (Bellariva), Lungarno Aldo Moro, Firenze", "Lungarno Aldo Moro Firenze" ],
        [ "Piscina del Polo natatorio Bruno Bianchi, Passeggio S. Andrea n. 8, Trieste", "Passeggio S. Andrea, n. 8" ],
        [ "Piscina comunale della ASD LARUS NUOTO in via Largo dei Veterani Viterbo", "via Largo dei Veterani Viterbo" ],
        [ "Piscina “Palazzo del Nuoto” di Torino, sita in Via Filadelfia n. 89", "Via Filadelfia, n. 89" ],
        [ "Piscina degli Impianti Natatori Comunali di Umbertide (PG) Via Rodolfo Morandi n°6", "Via Rodolfo Morandi, n°6" ],
        [ "Piscina del “Multieventi Sport Domus” di Serravalle, Repubblica di San Marino, Via Rancaglia 30", "Via Rancaglia, 30" ],
        [ "Piscina della Canottieri Baldesio, sita in Via al Porto 3, Cremona", "Via al Porto, 3" ],
        [ "Piscina dell' OTRE' WELLNESS CLUB sito in via Zona B39/F C.da Montedoro a Noci (BA", "via Zona B39/F" ],
        [ "Piscina piscina olimpica del Villaggio Ge-Tur, in via centrale, 29 - 33054 Lignano Sabbiadoro (UD", "via centrale, 29" ],
        [ "Sport Center di Priolo Gargallo, sito in Via Pirandello, 13", "Via Pirandello, 13" ],
        [ "Piscina dello Stadio del Nuoto di Cuneo - Via porta Mondovì 7 Cuneo (CN", "Via porta Mondovì, 7" ],
        [ "Piscina Comunale Il Grillo, contrada San Domenico 125/A", "contrada San Domenico, 125/A" ],
        [ "Piscina Comunale Sicbaldi Terramaini, via Pisano", "via Pisano" ],
        [ "Piscina del C.S. Plebiscito Padova, sita in via Geremia 2/2 (laterale di Via del Plebiscito 1866", "via Geremia, 2/2" ],
        [ "Piscina“La Bastia” Via Mastacchi 188 - Livorno", "Via Mastacchi, 188" ],
        [ "Piscina comunale, palazzetto dello sport \"Emilio Zoli\", via della Costituzione, 37 - Pontedera. In caso di maltempo la gara verrà effettuata nella vasca coperta da 25 m", "via della Costituzione, 37" ],
        [ "Complesso Comunale “Piscine Olimpioniche di Nesima”, via Filippo Eredia 1", "via Filippo Eredia, 1" ],
        [ "Piscina di ROMAN Sport City, in via Pontina km. 30 a Pomezia", "via Pontina, km 30" ],
        [ "Piscine di Albaro Piazza H. Dunant 4/22 - Genova", "Piazza H. Dunant, 4/22" ],
        [ "Piscina del Centro Sportivo Portici, sita in via De Curtis (snc) Portici (NA", "via De Curtis, (snc)" ],
        [ "Piscina Piscina dell' Hotel Torre Artale, Contrada S. Onofrio, Trabia (Palermo", "Contrada S. Onofrio Trabia (Palermo" ],
        [ "Piscina del Centro Federale Pietralata, via del Tufo snc, Roma", "via del Tufo, snc" ],
        [ "Piscina Comunale di Busto Garolfo, in via Busto Arsizio snc, angolo v.le Europa", "via Busto Arsizio, snc" ],
        [ "Piscina dello \"Stadio Comunale - Carmen Longo\" - Via dello Sport a Bologna - Zona Stadio", "Via dello Sport a Bologna Zona Stadio" ],
        [ "Piscina Plaia di Catania sita in Viale Kennedy 20", "Viale Kennedy, 20" ],
        [ "Piscina Comunale di Bitonto (BA), via del Petto snc - vasca 25 mt, 6 corsie", "via del Petto, snc" ],
        [ "Piscina coperta del Circolo Forum Roma Sport Center, Via Cornelia n. 493 Roma (Zona Aurelio", "Via Cornelia, n. 493" ],
        [ "Le gare si svolgeranno presso la Piscina del GEOVILLAGE CENTRO NUOTO - Circonvallazione Nord Direzione Golfo Aranci- OLBIA Tel. 0789 1234567.", "Circonvallazione Nord Direzione Golfo Aranci OLBIA" ],
        [ "Le gare si svolgeranno presso la Piscina Acquambiente, via Cà Nove, 7/A, 35040, Sant’Urbano (PD)\r\nCaratteristiche dell'impianto :\r\n", "via Cà Nove, 7/A" ]
      ].each do |pool_text, expected_result|
        context "for the text ('#{pool_text}')," do
          it "is the expected result (#{expected_result})" do
            expect( FinCalendarSwimmingPoolBuilder.parse_pool_address_tokens(pool_text).join(' ') ).to eq(expected_result)
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#report" do
      let(:source_text_line)    { "Piscine di Albaro Piazza H. Dunant 4/22 - Genova" }
      let(:expected_addr)       { "Albaro Piazza H. Dunant 4/22" }

      let(:meeting_place)       { "Genova" }
      let(:session_order)       { rand * 6 + 1 }
      let(:day_token)           { (rand * 31 + 1).to_s }
      let(:month_token)         { I18n.t("date.month_names")[rand * 13 + 1] }
      let(:parse_result_dao) do
        dao = FinCalendarParseResultDAO.new(day_token, month_token, session_order, source_text_line)
        dao.meeting_place = meeting_place
        dao
      end
      subject { FinCalendarSwimmingPoolBuilder.new( User.find(1), parse_result_dao, parse_result_dao.source_text_line, false ) }

      context "right from the start," do
        it "creates a log header" do
          output = []
          expect{ subject.report( output, :<< ) }.to change{ output }
        end
        it "includes the source_text_line in the process log" do
          output = []
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to include( expected_addr )
          expect( output.join("\r\n") ).to include( meeting_place )
        end
      end

      context "after a #find_or_create! call," do
        it "reports that the specified City was found (somewhere)" do
          output = []
          subject.find_or_create!() # force_geocoding_search = false (this should skip the API call)
          # Make the end report:
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to include( "Pool found!" )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.has_different_values?()" do
      let(:random_pool_read_only)   { pool = SwimmingPool.all.sample; pool.do_not_update = true; pool.save!; pool }
      let(:random_pool_updatable)   { pool = SwimmingPool.all.sample; pool.do_not_update = false; pool.save!; pool }

      let(:name)                    { random_pool_updatable.name }
      let(:address)                 { random_pool_updatable.address }
      let(:nick_name)               { random_pool_updatable.nick_name }

      context "for a nil SwimmingPool," do
        it "is false" do
          expect(
            FinCalendarSwimmingPoolBuilder.has_different_values?( nil, name, address, nick_name )
          ).to be false
        end
      end

      context "for a valid, updatable SwimmingPool compared w/ same values," do
        it "is false" do
          expect(
            FinCalendarSwimmingPoolBuilder.has_different_values?(
              random_pool_updatable,
              random_pool_updatable.name,
              random_pool_updatable.address,
              random_pool_updatable.nick_name
            )
          ).to be false
        end
      end

      context "for a valid, updatable SwimmingPool compared w/ DIFFERENT values," do
        it "is true" do
          expect(
            FinCalendarSwimmingPoolBuilder.has_different_values?(
              random_pool_updatable,
              random_pool_updatable.name + " #{ FFaker::Lorem.word }",
              random_pool_updatable.address,
              random_pool_updatable.nick_name
            )
          ).to be true
        end
      end

      context "for a READ-ONLY SwimmingPool compared w/ DIFFERENT values," do
        it "is false" do
          expect(
            FinCalendarSwimmingPoolBuilder.has_different_values?(
              random_pool_read_only,
              random_pool_read_only.name + " #{ FFaker::Lorem.word }",
              random_pool_read_only.address,
              random_pool_read_only.nick_name
            )
          ).to be false
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#find_or_create!" do
      context "when called for an existing Pool (w/ GeoCoding NOT forced & a different code (fixture #1)," do
        let(:source_text_line) do
<<-DOC_END
        Le gare si svolgeranno nella vecchia vasca da 25 metri
        della Piscina Comunale "Carmen Longo", (Stadio Comunale) Bologna,
        Via dello Sport, 2.
        Caratteristiche dell'impianto :
        Vasca coperta 25 mt, 8 corsie
        Cronometraggio automatico
DOC_END
        end
        let(:meeting_place)       { "Bologna" }
        let(:expected_pool)       { pool = SwimmingPool.find(4); pool.do_not_update = false; pool.save!; pool }

        let(:session_order)       { rand * 6 + 1 }
        let(:day_token)           { (rand * 31 + 1).to_s }
        let(:month_token)         { I18n.t("date.month_names")[rand * 13 + 1] }
        let(:parse_result_dao) do
          dao = FinCalendarParseResultDAO.new(day_token, month_token, session_order, source_text_line)
          dao.meeting_place = meeting_place
          dao
        end
        subject { FinCalendarSwimmingPoolBuilder.new( User.find(1), parse_result_dao, parse_result_dao.source_text_line, false ) }

        it "sets the #result_swimming_pool member to the expected SwimmingPool row (& updates the DB)" do
          # Let's make sure that we really have a fixture like that in the DB:
          expect( expected_pool ).to be_a( SwimmingPool )
          subject.find_or_create!() # force_geocoding_search = false (this should skip the API call)
          expect( subject.result_swimming_pool ).to be_a( SwimmingPool )
          expect( subject.result_swimming_pool.id ).to eq( expected_pool.id )
          expect( subject.has_updated ).to be true
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be true
        end
      end


      context "when called for an existing Pool (w/ GeoCoding NOT forced & a different code (fixture #2)," do
        let(:source_text_line) do
<<-DOC_END
        Le gare si svolgeranno presso la Piscina coperta del Circolo Forum Roma Sport Center,
        Via Cornelia n. 493 Roma (Zona Aurelio).
        Caratteristiche dell'impianto :
        Vasca coperta 25 mt, 8 corsie
        Cronometraggio automatico
DOC_END
        end
        let(:meeting_place)       { "Roma" }
        let(:expected_pool) do
          pool = SwimmingPool.find(95)
          pool.nick_name = "romaforum25" # ("romaforum25" old code before data normalization)
          pool.do_not_update = false
          pool.save!
          pool
        end

        let(:session_order)       { rand * 6 + 1 }
        let(:day_token)           { (rand * 31 + 1).to_s }
        let(:month_token)         { I18n.t("date.month_names")[rand * 13 + 1] }
        let(:parse_result_dao) do
          dao = FinCalendarParseResultDAO.new(day_token, month_token, session_order, source_text_line)
          dao.meeting_place = meeting_place
          dao
        end
        subject { FinCalendarSwimmingPoolBuilder.new( User.find(1), parse_result_dao, parse_result_dao.source_text_line, false ) }

        it "sets the #result_swimming_pool member to the expected SwimmingPool row (& updates the DB)" do
          # Let's make sure that we really have a fixture like that in the DB:
          expect( expected_pool ).to be_a( SwimmingPool )
          subject.find_or_create!() # force_geocoding_search = false (this should skip the API call)
          expect( subject.result_swimming_pool ).to be_a( SwimmingPool )
          expect( subject.result_swimming_pool.id ).to eq( expected_pool.id )
          expect( subject.has_updated ).to be true
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be true
        end
      end


      context "when called for an existing Pool (w/ GeoCoding NOT forced & a perfect match)," do
        # To have a perfect match, we need a pool that has all the components in the
        # nick_name: city token, name token and type token, and is already normalized:
        let(:expected_pool)       { SwimmingPool.where("(nick_name NOT LIKE '%6%') AND (nick_name NOT LIKE '%8%') AND (nick_name NOT LIKE '%del%') AND (address LIKE '%,%') AND (address NOT LIKE '%traversa%') AND (nick_name LIKE '%25%')").all.sample }

        let(:meeting_place)       { expected_pool.city.name }
        let(:source_text_line) do
          "Piscina #{ expected_pool.name } di #{ expected_pool.city.name }, #{ expected_pool.address }"
        end
        let(:session_order)       { rand * 6 + 1 }
        let(:day_token)           { (rand * 31 + 1).to_s }
        let(:month_token)         { I18n.t("date.month_names")[rand * 13 + 1] }
        let(:parse_result_dao) do
          dao = FinCalendarParseResultDAO.new(day_token, month_token, session_order, source_text_line)
          dao.meeting_place = meeting_place
          dao
        end
        subject { FinCalendarSwimmingPoolBuilder.new( User.find(1), parse_result_dao, parse_result_dao.source_text_line, true ) }

        it "sets the #result_swimming_pool member to the expected SwimmingPool row (w/ NO updates to the DB)" do
          # Let's make sure that we really have a fixture like that in the DB:
          expect( expected_pool ).to be_a( SwimmingPool )
          subject.find_or_create!() # force_geocoding_search = false (this should skip the API call)
          expect( subject.result_swimming_pool ).to be_a( SwimmingPool )
# DEBUG
          subject.report
          expect( subject.result_swimming_pool.id ).to eq( expected_pool.id )
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be false
        end
      end


      context "when called for an existing Pool (w/ GeoCoding NOT forced & slightly different address present)," do
        let(:source_text_line)    { "Piscine di Albaro Piazza H. Dunant 4/22 - Genova" }
        let(:meeting_place)       { "Genova" }
        let(:expected_pool) do
          pool = SwimmingPool.find(138)
          # Let's make sure the pool has a slightly different address:
          pool.address = "Piazza Dunant 22"
          pool.do_not_update = false
          expect( pool.save ).to be true
# DEBUG
#          puts pool.inspect
          pool
        end

        let(:session_order)       { rand * 6 + 1 }
        let(:day_token)           { (rand * 31 + 1).to_s }
        let(:month_token)         { I18n.t("date.month_names")[rand * 13 + 1] }
        let(:parse_result_dao) do
          dao = FinCalendarParseResultDAO.new(day_token, month_token, session_order, source_text_line)
          dao.meeting_place = meeting_place
          dao
        end
        subject { FinCalendarSwimmingPoolBuilder.new( User.find(1), parse_result_dao, parse_result_dao.source_text_line, false ) }

        it "sets the #result_swimming_pool member to the expected SwimmingPool row (& updates the DB)" do
          # Let's make sure that we really have a fixture like that in the DB:
          expect( expected_pool ).to be_a( SwimmingPool )
          subject.find_or_create!() # force_geocoding_search = false (this should skip the API call)
          expect( subject.result_swimming_pool ).to be_a( SwimmingPool )
# DEBUG
#          subject.report
          expect( subject.result_swimming_pool.id ).to eq( expected_pool.id )
          expect( subject.has_updated ).to be true
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be true
        end
      end


      context "when called for an existing Pool (w/ GeoCoding NOT forced & NO address)," do
        let(:source_text_line)    { "Vasca coperta 25 mt, 6 corsie\r\n\r\nCronometraggio automatico\r\n\r\n06 dicembre - domenica" }
        let(:meeting_place)       { "Massarosa" }
        let(:expected_pool)       { SwimmingPool.where( "nick_name LIKE '%massarosa%'" ).first }

        let(:session_order)       { rand * 6 + 1 }
        let(:day_token)           { (rand * 31 + 1).to_s }
        let(:month_token)         { I18n.t("date.month_names")[rand * 13 + 1] }
        let(:parse_result_dao) do
          dao = FinCalendarParseResultDAO.new(day_token, month_token, session_order, source_text_line)
          dao.meeting_place = meeting_place
          dao
        end
        subject { FinCalendarSwimmingPoolBuilder.new( User.find(1), parse_result_dao, parse_result_dao.source_text_line, false ) }

        it "sets the #result_swimming_pool member to the expected SwimmingPool row (w/ NO changes to the DB)" do
          # Let's make sure that we really have a fixture like that in the DB:
          expect( expected_pool ).to be_a( SwimmingPool )
          subject.find_or_create!() # force_geocoding_search = false (this should skip the API call)
          expect( subject.result_swimming_pool ).to be_a( SwimmingPool )
# DEBUG
#          subject.report
          expect( subject.result_swimming_pool.id ).to eq( expected_pool.id )
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be false
        end
      end


      context "when called for a NOT-yet existing Pool (w/ GeoCoding NOT forced)," do
        let(:source_text_line)    { "Piscina del Circolo Tennis, Albinea, RE, 42020" }
        let(:meeting_place)       { "Albinea" }
        let(:session_order)       { rand * 6 + 1 }
        let(:day_token)           { (rand * 31 + 1).to_s }
        let(:month_token)         { I18n.t("date.month_names")[rand * 13 + 1] }
        let(:parse_result_dao) do
          dao = FinCalendarParseResultDAO.new(day_token, month_token, session_order, source_text_line)
          dao.meeting_place = meeting_place
          dao
        end
        subject { FinCalendarSwimmingPoolBuilder.new( User.find(1), parse_result_dao, parse_result_dao.source_text_line, false ) }

        it "returns a SwimmingPool instance and creates a new pool with the expected new name (CHANGING the DB)" do
          # Let's make sure that the fixture doesn't exist in the DB:
          expect( SwimmingPool.where( "nick_name LIKE '%albinea%'" ).count ).to eq(0)
          subject.find_or_create!() # force_geocoding_search = false (this should skip the API call)
# DEBUG
#          subject.report
          expect( subject.result_swimming_pool ).to be_a( SwimmingPool )
          expect( subject.result_swimming_pool.name ).to eq( "Circolo Tennis Albinea RE" )
          expect( subject.result_swimming_pool.id ).to be > 0
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be true
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be true
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
      expect{ FinCalendarSwimmingPoolBuilder.new }.to raise_error( ArgumentError )
      expect{ FinCalendarSwimmingPoolBuilder.new(nil, nil, nil) }.to raise_error( ArgumentError )
      expect{ FinCalendarSwimmingPoolBuilder.new(nil, "", nil) }.to raise_error( ArgumentError )
      expect{ FinCalendarSwimmingPoolBuilder.new(nil, nil, "") }.to raise_error( ArgumentError )
      expect{ FinCalendarSwimmingPoolBuilder.new(1, 1, 1) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
