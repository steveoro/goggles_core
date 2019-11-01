require 'rails_helper'


describe FinCalendarTextParser, type: :strategy do

  # Static fixture text from season 162:
  before(:all) do
    sample_text = File.open( File.join( Rails.root, 'spec/fixtures/samples/sample_fin_programs_text_162.txt' ) ).read
    @fixture_list = sample_text.split("***[END]***")
  end

  let( :fin_calendar_row )  { create(:fin_calendar) }
  #-- -------------------------------------------------------------------------
  #++


  context "with valid parameters," do
    subject { FinCalendarTextParser.new( fin_calendar_row ) }

    it_behaves_like( "(the existance of a method)", [
      :source_row, :session_daos,
      :parse!
    ] )

    it_behaves_like( "(the existance of a class method)", [
      :contains_a_date?, :contains_a_time?, :contains_a_style?,
      :contains_individual_event?, :contains_a_warmup?, :contains_a_relay_event?,
      :contains_a_footnote?, :contains_skippable_text?,
      :get_filtered_program_lines,
      :parse_event_length_in_meters, :parse_event_relay_phases,
      :extract_style_token,
      :extract_possible_pool_definition,
      :parse_pool_type, :parse_pool_lanes_number,
      :get_filtered_pool_data_text, :get_filtered_pool_data_tokens, :split_in_sentences,
      :subtract_set_behaviour,
      :event_line_token_splitter
    ] )


    describe "#source_row" do
      it "is the FinCalendar instance specified in the constructor" do
        expect( subject.source_row ).to eq( fin_calendar_row )
      end
    end

    describe "#session_daos" do
      it "is an empty Array" do
        expect( subject.session_daos ).to eq( [] )
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.contains_a_pool?" do
      [
        "piscina comunale di Carpi", "Piscina di Viareggio", "Complesso piscine nuove di Reggio Emilia",
        "Piscina Stadio del Nuoto", "Piscina del Complesso Centro sportivo AquaFun",
        "Le gare si svolgeranno nella nuova vasca da 50 metri della Piscina Comunale"
      ].each do |fixture_text|
        context "for a valid text ('#{ fixture_text }')," do
          it "is true" do
            expect( FinCalendarTextParser.contains_a_pool?(fixture_text) ).to be true
          end
        end
      end

      [
        "vasca di riscaldamento", "8 corsie, 50 mt.", "blablabla/blabla"
      ].each do |fixture_text|
        context "for an invalid text ('#{ fixture_text }')," do
          it "is false" do
            expect( FinCalendarTextParser.contains_a_pool?(fixture_text) ).to be false
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.contains_a_date?" do
      [
        "11 ottobre", "4 aprile", "01 maggio", "39 giuglio"
      ].each do |fixture_text|
        context "for a valid text ('#{ fixture_text }')," do
          it "is true" do
            expect( FinCalendarTextParser.contains_a_date?(fixture_text) ).to be true
          end
        end
      end

      [
        "11-10", "4 domenica", "42 zorro", "blablabla/blabla"
      ].each do |fixture_text|
        context "for an invalid text ('#{ fixture_text }')," do
          it "is false" do
            expect( FinCalendarTextParser.contains_a_date?(fixture_text) ).to be false
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.contains_a_time?" do
      [
        "ore 8.00", "ore 8:00", "ore 10 00"
      ].each do |fixture_text|
        context "for a valid text ('#{ fixture_text }')," do
          it "is true" do
            expect( FinCalendarTextParser.contains_a_time?(fixture_text) ).to be true
          end
        end
      end

      [
        "10:15", "8.00", "mattino"
      ].each do |fixture_text|
        context "for an invalid text ('#{ fixture_text }')," do
          it "is false" do
            expect( FinCalendarTextParser.contains_a_time?(fixture_text) ).to be false
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.contains_a_style?" do
      [
        "50SL", "50 sl", "50 stile", "100 SL", "200 SL", "400 SL", "1500 sl",
        "50DO", "50 do", "50 dorso", "100 DO", "200 DO",
        "50RA", "50 ra", "50 rana", "100 RA", "200 RA",
        "50FA", "50 fa", "100 FA", "200 FA",
        "50DF", "50 DF", "100 DF", "200 DF",
        "50DL", "50 Dl", "100 DL", "200 DL",
        "50MI", "50 MI", "50 MX", "100 MI", "200 MI", "400 MI", "400 misti",

        "200metri Farfalla", "50metri Dorso", "200metri Stile Libero", "100metri Dorso",
        "100metri Misti", "50metri Stile Libero", "800metri Stile libero",
        "200m Farfalla", "50m Dorso", "200m Stile Libero", "100m Dorso",
        "100m Misti", "50m Stile Libero", "800m Stile libero",
        "50m. Rana", "200m. Misti", "50m. Farfalla", "200m. Dorso",
        "100m. Rana", "100m. Stile Libero",

        "200 m Farfalla", "50 m Dorso", "200 m Stile Libero", "100 m Dorso",
        "100 m Misti", "50 m Stile Libero", "800 m Stile libero",
        "50 m. Rana", "200 m. Misti", "50 m. Farfalla", "200 m. Dorso",
        "100 m. Rana", "100 m. Stile Libero",
        "50 mt Rana", "200 mt Misti", "50 mt Farfalla", "200 mt Dorso",
        "100 mt Rana", "100 mt Stile Libero",
        "50 mt. Rana", "200 mt. Misti", "50 mt. Farfalla", "200 mt. Dorso",
        "100 mt. Rana", "100 mt. Stile Libero",
        "200 metri Farfalla", "50 metri Dorso", "200 metri Stile Libero", "100 metri Dorso",
        "100 metri Misti", "50 metri Stile Libero", "800 metri Stile libero",

        "MiStaff 4x50 Stile Libero", "MiStaff 4x50 m. Stile Libero",
        "MiStaff 4x50 mt Stile Libero", "MiStaff 4x50 mt. Stile Libero",

        "400 stika"
      ].each do |fixture_text|
        context "for a valid text ('#{ fixture_text }')," do
          it "is true" do
            expect( FinCalendarTextParser.contains_a_style?(fixture_text) ).to be true
          end
        end
      end

      [
        "100 niente", "200 smisto", "300 sparta", "33 Rana", "66 m. Delfo",
        "vasca da 50 metri dell'impianto coperto",
        "i 50 metri della piscina",
        "Le gare si svolgeranno nella nuova vasca da 50 metri della Piscina Comunale"
      ].each do |fixture_text|
        context "for an invalid text ('#{ fixture_text }')," do
          it "is false" do
            expect( FinCalendarTextParser.contains_a_style?(fixture_text) ).to be false
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.contains_a_warmup?" do
      [
        "riscaldamento quanto vuoi"
      ].each do |fixture_text|
        context "for a valid text ('#{ fixture_text }')," do
          it "is true" do
            expect( FinCalendarTextParser.contains_a_warmup?(fixture_text) ).to be true
          end
        end
      end

      [
        "ristoro", "risca"
      ].each do |fixture_text|
        context "for an invalid text ('#{ fixture_text }')," do
          it "is false" do
            expect( FinCalendarTextParser.contains_a_warmup?(fixture_text) ).to be false
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.contains_a_footnote?" do
      [
        "* 1500 SL numero chiuso",
        "** 800 SL max 30 atleti",
        "(a) 800 SL sessione chiusa",
        "(1) 800 SL a numero limitato",
        "(i) 400 SL max 60 atleti",
        "(ii) 400 SL 2 per corsia",
        "(*) 800 SL a targhe alterne",
        "(**) 800 SL ciao"
      ].each do |fixture_text|
        context "for a valid text ('#{ fixture_text }')," do
          it "is true" do
            expect( FinCalendarTextParser.contains_a_footnote?(fixture_text) ).to be true
          end
        end
      end

      [
        "1500 SL *", "800 SL **", "800 SL (a)", "800 SL (1)",
        "400 SL (i)", "400 SL (ii)", "800 SL (*)", "800 SL (**)"
      ].each do |fixture_text|
        context "for an invalid text ('#{ fixture_text }')," do
          it "is false" do
            expect( FinCalendarTextParser.contains_a_footnote?(fixture_text) ).to be false
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.contains_skippable_text?" do
      [
        "Cronometraggio automatico / manuale per 800SL e 1500SL",
        "Cronometraggio automatico con doppie piastre  3 corsie per riscaldamento nella vasca da 25 metri"
      ].each do |fixture_text|
        context "for a valid text ('#{ fixture_text }')," do
          it "is true" do
            expect( FinCalendarTextParser.contains_skippable_text?(fixture_text) ).to be true
          end
        end
      end

      [
        "1500 SL *", "800 SL **", "800 SL (a)", "800 SL (1)",
        "400 SL (i)", "400 SL (ii)", "800 SL (*)", "800 SL (**)"
      ].each do |fixture_text|
        context "for an invalid text ('#{ fixture_text }')," do
          it "is false" do
            expect( FinCalendarTextParser.contains_skippable_text?(fixture_text) ).to be false
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.contains_a_relay_event?" do
      [
        "staff 4x50SL", "staff 4x50 sl", "staff 4x50 stile",
        "MiStaff 4x100 SL", "Mistaff 4x200 SL",
        "staff 4x100 SL", "staff 4x200 SL",
        "Staff 4x50MI", "Staffetta  4x50 mx", "staff  4 x 50 MX", "staff  4 x 100 MI",
        "staff  4 x 50SL", "staff  4x 50 sl", "staff  4x50 stile",
        "MiStaff  4x100 SL", "Mistaff  4x200 SL",
        "staff  4 x 100 SL", "staff  4x 200 SL",
        "Staff 4x50 Misti", "Mistaffetta 4 x 50 Mista",
        "Staff 4 x 100 stile libero", "Mistaffetta 4 x 200 Stile",
        "Mistaff 4x200 MI", "Mistaff 4x200 MX",
        "4 x 50MI", "4x 50 MI", "4 x 50 MX", "4 x 100 MI",
        "4x50MI", "4x50 MI", "4x50 MX", "4x100 MI",
        "4x50SL", "8x50 ST", "4x100 sl", "4x50 stile",
        "MiStaff 4x50 Stile Libero", "MiStaff 4x50 m. Stile Libero",
        "Staff 4x100 metri SL", "Staff 4x 50 metri MX",
        "MiStaff 4x50 mt Stile Libero", "MiStaff 4x50 mt. Stile Libero"
      ].each do |fixture_text|
        context "for a valid text ('#{ fixture_text }')," do
          it "is true" do
            expect( FinCalendarTextParser.contains_a_relay_event?(fixture_text) ).to be true
          end
        end
      end

      [
        "50SL", "50 sl", "50 stile", "100 SL",
        "4x50 cavalli", "4x50 madonne", "5x1000",
        "200 SL", "400 SL", "1500 sl",
        "50FA", "50 fa", "100 FA", "200 FA", "400 FA",
        "50DF", "50 DF", "100 DF", "200 DF", "400 DF",
        "50DL", "50 Dl", "100 DL", "200 DL", "400 DL",
        "50MI", "50 MI", "50 MX", "100 MI", "200 MI", "400 MI", "400 misti",
        "4x niente",
        "Le gare si svolgeranno nella nuova vasca da 50 metri della Piscina Comunale"
      ].each do |fixture_text|
        context "for an invalid text ('#{ fixture_text }')," do
          it "is false" do
            expect( FinCalendarTextParser.contains_a_relay_event?(fixture_text) ).to be false
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.contains_individual_event?" do
      [
        "50SL", "50 sl", "50 stile", "100 SL",
        "200 SL", "400 SL", "1500 sl",
        "50FA", "50 fa", "100 FA", "200 FA", "400 FA",
        "50DF", "50 DF", "100 DF", "200 DF", "400 DF",
        "50DL", "50 Dl", "100 DL", "200 DL", "400 DL",
        "50MI", "50 MI", "50 MX", "100 MI", "200 MI", "400 MI", "400 misti",

        "200metri Farfalla", "50metri Dorso", "200metri Stile Libero", "100metri Dorso",
        "100metri Misti", "50metri Stile Libero", "800metri Stile libero",
        "200m Farfalla", "50m Dorso", "200m Stile Libero", "100m Dorso",
        "100m Misti", "50m Stile Libero", "800m Stile libero",
        "50m. Rana", "200m. Misti", "50m. Farfalla", "200m. Dorso",
        "100m. Rana", "100m. Stile Libero",
        "200 m Farfalla", "50 m Dorso", "200 m Stile Libero", "100 m Dorso",
        "100 m Misti", "50 m Stile Libero", "800 m Stile libero",
        "50 m. Rana", "200 m. Misti", "50 m. Farfalla", "200 m. Dorso",
        "100 m. Rana", "100 m. Stile Libero",
        "50 mt Rana", "200 mt Misti", "50 mt Farfalla", "200 mt Dorso",
        "100 mt Rana", "100 mt Stile Libero",
        "50 mt. Rana", "200 mt. Misti", "50 mt. Farfalla", "200 mt. Dorso",
        "100 mt. Rana", "100 mt. Stile Libero",
        "200 metri Farfalla", "50 metri Dorso", "200 metri Stile Libero", "100 metri Dorso",
        "100 metri Misti", "50 metri Stile Libero", "800 metri Stile libero"
      ].each do |fixture_text|
        context "for a valid text ('#{ fixture_text }')," do
          it "is true" do
            expect( FinCalendarTextParser.contains_individual_event?(fixture_text) ).to be true
          end
        end
      end

      [
        "1000 st", "33 DO", "66 m. FA",
        "vasca da 50 metri dell'impianto coperto",
        "staff 4x50SL", "staff 4x50 sl", "staff 4x50 stile",
        "MiStaff 4x100 SL", "Mistaff 4x200 SL",
        "staff 4x100 SL", "staff 4x200 SL",
        "Staff 4x50MI", "Staff 4x50 MI", "staff 4x50 MX", "staff 4x100 MI",
        "Staff 4x50 Misti", "Mistaffetta 4 x 50 Mista",
        "Staff 4 x 100 stile libero", "Mistaffetta 4 x 200 Stile",
        "Mistaff 4x200 MI", "Mistaff 4x200 MX",
        "4 x 50MI", "4x 50 MI", "4 x 50 MX", "4 x 100 MI",
        "4x50MI", "4x50 MI", "4x50 MX", "4x100 MI",
        "4x50SL", "8x50 ST", "4x100 sl", "4x50 stile",
        "4x50 cavalli", "4x50 madonne", "5x1000",
        "MiStaff 4x50 Stile Libero", "MiStaff 4x50 m. Stile Libero",
        "MiStaff 4x50 mt Stile Libero", "MiStaff 4x50 mt. Stile Libero",
        "4x niente",
        "Le gare si svolgeranno nella nuova vasca da 50 metri della Piscina Comunale"
      ].each do |fixture_text|
        context "for an invalid text ('#{ fixture_text }')," do
          it "is false" do
            expect( FinCalendarTextParser.contains_individual_event?(fixture_text) ).to be false
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.get_filtered_program_lines()" do
      it "returns an array of lines, each one either containing a date, a time or an event" do
        fixture_text = @fixture_list.sample
        FinCalendarTextParser.get_filtered_program_lines( fixture_text ).each do |line|
          expect(
            ( FinCalendarTextParser.contains_a_pool?( line ) ||
              FinCalendarTextParser.contains_a_date?( line ) ||
              FinCalendarTextParser.contains_a_time?( line ) ||
              FinCalendarTextParser.contains_a_style?( line ) ||
              ( FinCalendarTextParser.contains_a_style?(line) && !FinCalendarTextParser.contains_skippable_text?(line) ) ||
              FinCalendarTextParser.contains_a_footnote?( line ) ||
              ( FinCalendarTextParser.contains_a_relay_event?( line ) && !FinCalendarTextParser.contains_skippable_text?(line) )
            )
          ).to be true
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.extract_style_token()" do
      [
        [ "50 SL", "SL"],
        [ "50 St", "St"],
        [ "50DO", "DO"],
        [ "100 stile", "st"],
        [ "100FA", "FA"],
        [ "100 do", "do"],
        [ "100 misti", "mi"],
        [ "100 RA", "RA"],
        [ "200 rana", "ra"],
        [ "200 Misto", "Mi"],
        [ "200MI", "MI"],
        [ "100MX", "MX"],
        [ "100MI", "MI"],
        [ "400 MX", "MX"],
        [ "400 MI", "MI"],
        [ "staff 4x50 stile", "st"],
        [ "Staff 4x50 MI", "MI"],
        [ "staff 4x100 st", "st"],
        [ "staff 4x100 MX", "MX"],
        [ "Staff 4x100MI", "MI"],

        [ "staff 4x 50 stile", "st"],
        [ "Staff 4x 50 MI", "MI"],
        [ "staff 4x 100 st", "st"],
        [ "staff 4x 100 MX", "MX"],
        [ "Staff 4x 100MI", "MI"],
        [ "staff 4 x 50 stile", "st"],
        [ "Staff 4 x 50 MI", "MI"],
        [ "staff 4 x 100 st", "st"],
        [ "staff 4 x 100 MX", "MX"],
        [ "Staff 4 x 100MI", "MI"],
        [ "staff  4 x 50 stile", "st"],
        [ "Staff  4 x 50 MI", "MI"],
        [ "staff  4 x 100 sl", "sl"],
        [ "staff  4 x 100 MX", "MX"],
        [ "Staff  4 x 100MI", "MI"],

        [ "50m Dorso", "Do"],
        [ "50 m Stile libero", "St"],
        [ "100 m Farfalla", "Fa"],
        [ "100 m Delfino", "De"],
        [ "200 m Rana", "Ra"],
        [ "400 m Dorso", "Do"],
        [ "400 m Misti", "Mi"],
        [ "50m. Dorso", "Do"],
        [ "50 m. Stile libero", "St"],
        [ "100 m. Farfalla", "Fa"],
        [ "100 m. Delfino", "De"],
        [ "200 m. Rana", "Ra"],
        [ "400 m. Misti", "Mi"],
        [ "50mt Dorso", "Do"],
        [ "50 mt Stile libero", "St"],
        [ "100 mt Farfalla", "Fa"],
        [ "200 mt Rana", "Ra"],
        [ "400 mt Misti", "Mi"],

        [ "50mt. Dorso", "Do"],
        [ "50 mt. Stile libero", "St"],
        [ "100 mt. Farfalla", "Fa"],
        [ "200 mt. Rana", "Ra"],
        [ "400 mt. Dorso", "Do"],
        [ "400 mt. Misti", "Mi"],
        [ "50metri Dorso", "Do"],
        [ "50 metri Stile libero", "St"],
        [ "100 metri Farfalla", "Fa"],
        [ "200 metri Rana", "Ra"],
        [ "400 metri Misti", "Mi"],

        [ "4x50 sl", "sl"],
        [ "4x50 MI", "MI"],
        [ "4x100 sl", "sl"],
        [ "4x100 MX", "MX"],
        [ "4x100MI", "MI"],
        [ "Mistaff 4x50 st", "st"],
        [ "staff 4x50 SL", "SL"],
        [ "MiStaff 4x50 MI", "MI"],
        [ "staff 4x100 sl", "sl"],
        [ "Mistaff 4x100 ST", "ST"],
        [ "staff 4x100 MX", "MX"],
        [ "MiStaff 4x100MI", "MI"],
        [ "staff 4x200 misti", "mi"],

        [ "Mistaffa 4x50 st", "st"],
        [ "staffa 4x50 SL", "SL"],
        [ "MiStaffa 4x50 MI", "MI"],
        [ "staffa 4x100 sl", "sl"],
        [ "Mistaffa 4x100 ST", "ST"],
        [ "staffa 4x100 MX", "MX"],
        [ "MiStaffa 4x100MI", "MI"],
        [ "staffa 4x200 misti", "mi"],
        [ "Mistaffa4x50 st", "st"],
        [ "staffa4x50 SL", "SL"],
        [ "MiStaffa4x50 MI", "MI"],
        [ "staffa4x100 sl", "sl"],
        [ "Mistaffa4x100 ST", "ST"],
        [ "staffa4x100 MX", "MX"],
        [ "MiStaffa4x100MI", "MI"],
        [ "staffa4x200 misti", "mi"],

        [ "MiStaff 4x50 Stile Libero", "St"],
        [ "staff 4x50m Stile Libero", "St"],
        [ "MiStaff 4x50mt Stile Libero", "St"],
        [ "staff 4x50 m Stile Libero", "St"],
        [ "MiStaff 4x50 m. Stile Libero", "St"],
        [ "staff 4x50 mt Stile Libero", "St"],
        [ "MiStaff 4x50 mt. Stile Libero", "St"],
        [ "staff 4x50 metri Stile Libero", "St"]
      ].each do |event_token, expected_result|
        context "for the event text '#{event_token}'," do
          it "is the expected result (#{expected_result})" do
            expect( FinCalendarTextParser.extract_style_token(event_token) ).to eq(expected_result)
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.parse_event_length_in_meters()" do
      [
        [ "50 SL", "SL", 50 ],
        [ "50 St", "st", 50 ],
        [ "50DO", "do", 50 ],
        [ "100 stile", "ST", 100 ],
        [ "100FA", "fa", 100 ],
        [ "100 do", "DO", 100 ],
        [ "100 misti", "mi", 100 ],
        [ "100 RA", "RA", 100 ],
        [ "200 rana", "RA", 200 ],
        [ "200 Misto", "mi", 200 ],
        [ "200MI", "mi", 200 ],
        [ "400 MX", "mx", 400 ],
        [ "400 MI", "mi", 400 ],
        [ "staff 4x50 stile", "st", 50 ],
        [ "Staff 4x50 MI", "mi", 50 ],
        [ "staff 4x100 st", "st", 100 ],
        [ "staff 4x100 MX", "mx", 100 ],
        [ "Staff 4x100MI", "mi", 100 ],

        [ "staff 4x 50 stile", "st", 50 ],
        [ "Staff 4x 50 MI", "mi", 50 ],
        [ "staff 4x 100 st", "st", 100 ],
        [ "staff 4x 100 MX", "mx", 100 ],
        [ "Staff 4x 100MI", "mi", 100 ],
        [ "staff 4 x 50 stile", "st", 50 ],
        [ "Staff 4 x 50 MI", "mi", 50 ],
        [ "staff 4 x 100 st", "st", 100 ],
        [ "staff 4 x 100 MX", "mx", 100 ],
        [ "Staff 4 x 100MI", "mi", 100 ],
        [ "staff  4 x 50 stile", "st", 50 ],
        [ "Staff  4 x 50 MI", "mi", 50 ],
        [ "staff  4 x 100 sl", "sl", 100 ],
        [ "staff  4 x 100 MX", "mx", 100 ],
        [ "Staff  4 x 100MI", "mi", 100 ],

        [ "50m Dorso", "Dorso", 50 ],
        [ "50 m Stile libero", "Stile libero", 50 ],
        [ "100 m Farfalla", "Farfalla", 100 ],
        [ "200 m Rana", "Rana", 200 ],
        [ "400 m Dorso", "Dorso", 400 ],
        [ "400 m Misti", "Misti", 400 ],

        [ "50m. Dorso", "Dorso", 50 ],
        [ "50 m. Stile libero", "Stile libero", 50 ],
        [ "100 m. Farfalla", "Farfalla", 100 ],
        [ "200 m. Rana", "Rana", 200 ],
        [ "400 m. Dorso", "Dorso", 400 ],
        [ "400 m. Misti", "Misti", 400 ],

        [ "50mt Dorso", "Dorso", 50 ],
        [ "50 mt Stile libero", "Stile libero", 50 ],
        [ "100 mt Farfalla", "Farfalla", 100 ],
        [ "200 mt Rana", "Rana", 200 ],
        [ "400 mt Dorso", "Dorso", 400 ],
        [ "400 mt Misti", "Misti", 400 ],

        [ "50mt. Dorso", "Dorso", 50 ],
        [ "50 mt. Stile libero", "Stile libero", 50 ],
        [ "100 mt. Farfalla", "Farfalla", 100 ],
        [ "200 mt. Rana", "Rana", 200 ],
        [ "400 mt. Dorso", "Dorso", 400 ],
        [ "400 mt. Misti", "Misti", 400 ],

        [ "50metri Dorso", "Dorso", 50 ],
        [ "50 metri Stile libero", "Stile libero", 50 ],
        [ "100 metri Farfalla", "Farfalla", 100 ],
        [ "200 metri Rana", "Rana", 200 ],
        [ "400 metri Dorso", "Dorso", 400 ],
        [ "400 metri Misti", "Misti", 400 ],

        [ "4x50 sl", "sl", 50 ],
        [ "4x50 MI", "mi", 50 ],
        [ "4x100 sl", "sl", 100 ],
        [ "4x100 MX", "mx", 100 ],
        [ "4x100MI", "mi", 100 ],
        [ "Mistaff 4x50 st", "st", 50 ],
        [ "staff 4x50 SL", "sl", 50 ],
        [ "MiStaff 4x50 MI", "mi", 50 ],
        [ "staff 4x100 sl", "sl", 100 ],
        [ "Mistaff 4x100 ST", "st", 100 ],
        [ "staff 4x100 MX", "mx", 100 ],
        [ "MiStaff 4x100MI", "mi", 100 ],
        [ "staff 4x200 misti", "mi", 200 ],

        [ "Mistaff4x50 st", "st", 50 ],
        [ "staff4x50 SL", "sl", 50 ],
        [ "MiStaff4x50 MI", "mi", 50 ],
        [ "staff4x100 sl", "sl", 100 ],
        [ "Mistaff4x100 ST", "st", 100 ],
        [ "staff4x100 MX", "mx", 100 ],
        [ "MiStaff4x100MI", "mi", 100 ],
        [ "staff4x200 misti", "mi", 200 ],

        [ "Mistaffa4x50 st", "st", 50 ],
        [ "staffa4x50 SL", "sl", 50 ],
        [ "MiStaffa4x50 MI", "mi", 50 ],
        [ "staffa4x100 sl", "sl", 100 ],
        [ "Mistaffa4x100 ST", "st", 100 ],
        [ "staffa4x100 MX", "mx", 100 ],
        [ "MiStaffa4x100MI", "mi", 100 ],
        [ "staffa4x200 misti", "mi", 200 ],

        [ "Mistaffa 4x50 st", "st", 50 ],
        [ "staffa 4x50 SL", "sl", 50 ],
        [ "MiStaffa 4x50 MI", "mi", 50 ],
        [ "staffa 4x100 sl", "sl", 100 ],
        [ "Mistaffa 4x100 ST", "st", 100 ],
        [ "staffa 4x100 MX", "mx", 100 ],
        [ "MiStaffa 4x100MI", "mi", 100 ],
        [ "staffa 4x200 misti", "mi", 200 ],

        [ "MiStaff 4x50 Stile Libero", "Stile Libero", 50 ],
        [ "staff 4x50m Stile Libero", "Stile Libero", 50 ],
        [ "MiStaff 4x50mt Stile Libero", "Stile Libero", 50 ],
        [ "staff 4x50 m Stile Libero", "Stile Libero", 50 ],
        [ "MiStaff 4x50 m. Stile Libero", "Stile Libero", 50 ],
        [ "staff 4x50 mt Stile Libero", "Stile Libero", 50 ],
        [ "MiStaff 4x50 mt. Stile Libero", "Stile Libero", 50 ],
        [ "staff 4x50 metri Stile Libero", "Stile Libero", 50 ]
      ].each do |event_token, style_token, expected_result|
        context "for the event text ('#{event_token}','#{style_token}')," do
          it "is the expected result (#{expected_result})" do
            expect( FinCalendarTextParser.parse_event_length_in_meters(event_token, style_token) ).to eq(expected_result)
          end
        end
      end
    end


    describe "self.parse_event_relay_phases()" do
      [
        [ "50 SL", false, 1 ],
        [ "50DO", false, 1 ],
        [ "100 stile", false, 1 ],
        [ "200 Misto", false, 1 ],
        [ "400 MX", false, 1 ],
        [ "400 MI", false, 1 ],
        [ "staff 4x50 sl", true, 4 ],
        [ "Mistaff 4x50 st", true, 4 ],
        [ "Staff 4x50 MI", true, 4 ],
        [ "staff 4x100 sl", true, 4 ],
        [ "staff 4x100 MX", true, 4 ],
        [ "Staff 4x100MI", true, 4 ],

        [ "staff  4x50 sl", true, 4 ],
        [ "Mistaff  4x50 st", true, 4 ],
        [ "Staff  4x50 MI", true, 4 ],
        [ "staff  4x100 sl", true, 4 ],
        [ "staff  4x100 MX", true, 4 ],
        [ "Staff  4x100MI", true, 4 ],
        [ "staff  4x 50 sl", true, 4 ],
        [ "Mistaff  4x 50 st", true, 4 ],
        [ "Staff  4x 50 MI", true, 4 ],
        [ "staff  4x 100 sl", true, 4 ],
        [ "staff  4x 100 MX", true, 4 ],
        [ "Staff  4x 100MI", true, 4 ],
        [ "staff  4 x 50 sl", true, 4 ],
        [ "Mistaff  4 x 50 st", true, 4 ],
        [ "Staff  4 x 50 MI", true, 4 ],
        [ "staff  4 x 100 sl", true, 4 ],
        [ "staff  4 x 100 MX", true, 4 ],
        [ "Staff  4 x 100MI", true, 4 ],

        [ "8x50 sl", true, 8 ],
        [ "4x50 MI", true, 4 ],
        [ "8x100 sl", true, 8 ],
        [ "4x100 MX", true, 4 ],
        [ "4x100MI", true, 4 ],

        [ "Staff 4x50 St", true, 4 ],
        [ "staff 8x50 sl", true, 8 ],
        [ "staff 4x50 stile", true, 4 ],
        [ "staff 8x50 ST", true, 8 ],
        [ "Staff 4x50 MI", true, 4 ],
        [ "staff 4x100 sl", true, 4 ],
        [ "staff 4x100 MX", true, 4 ],
        [ "Staff 4x100MI", true, 4 ],
        [ "Mistaff 4x200 misti", true, 4 ],
        [ "MiStaff 4x50 St", true, 4 ],
        [ "Mistaff 8x50 sl", true, 8 ],
        [ "Mistaff 4x50 stile", true, 4 ],
        [ "Mistaff 8x50 ST", true, 8 ],
        [ "MiStaff 4x50 MI", true, 4 ],
        [ "Mistaff 4x100 sl", true, 4 ],
        [ "Mistaff 4x100 MX", true, 4 ],
        [ "MiStaff 4x100MI", true, 4 ],
        [ "Mistaff 4x200 misti", true, 4 ],

        [ "Staff4x50 MI", true, 4 ],
        [ "Staff8x50 MX", true, 8 ],
        [ "Mistaff4x200 misti", true, 4 ],
        [ "MiStaff4x50 St", true, 4 ],
        [ "Mistaff8x50 sl", true, 8 ],
        [ "Mistaff4x50 stile", true, 4 ],
        [ "Mistaff8x50 ST", true, 8 ],

        [ "Staffa4x50 MI", true, 4 ],
        [ "Staffa8x50 MX", true, 8 ],
        [ "Mistaffa4x200 misti", true, 4 ],
        [ "MiStaffa4x50 St", true, 4 ],
        [ "Mistaffa8x50 sl", true, 8 ],
        [ "Mistaffa4x50 stile", true, 4 ],
        [ "Mistaffa8x50 ST", true, 8 ],

        [ "Staffa 4x50 MI", true, 4 ],
        [ "Staffa 8x50 MX", true, 8 ],
        [ "Mistaffa 4x200 misti", true, 4 ],
        [ "MiStaffa 4x50 St", true, 4 ],
        [ "Mistaffa 8x50 sl", true, 8 ],
        [ "Mistaffa 4x50 stile", true, 4 ],
        [ "Mistaffa 8x50 ST", true, 8 ],

        [ "MiStaff 4x50 Stile Libero", true, 4 ],
        [ "staff 8x50m Stile Libero", true, 8 ],
        [ "MiStaff 4x50mt Stile Libero", true, 4 ],
        [ "staff 8x50 m Stile Libero", true, 8 ],
        [ "MiStaff 4x50 m. Stile Libero", true, 4 ],
        [ "staff 8x50 mt Stile Libero", true, 8 ],
        [ "MiStaff 4x50 mt. Stile Libero", true, 4 ],
        [ "staff 4x50 metri Stile Libero", true, 4 ]
      ].each do |event_token, is_a_relay, expected_result|
        context "for the event text ('#{event_token}',#{is_a_relay})," do
          it "is the expected result (#{expected_result})" do
            expect( FinCalendarTextParser.parse_event_relay_phases(event_token, is_a_relay) ).to eq(expected_result)
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.get_filtered_pool_data_text()" do
      [
        [ "Le gare si svolgeranno presso la Piscina Olimpica Samuele di Milano, via Trani. Caratteristiche dell'impianto:", "Olimpica Samuele di Milano, via Trani" ],
        [ "Le gare si svolgeranno presso la Piscina Comunale di Verolanuova (BS) Viale Italia 9.  Caratteristiche dell'impianto :", "Comunale di Verolanuova (BS) Viale Italia 9" ],
        [ "Le gare si svolgeranno presso il Nuovo Polo Natatorio di Rovigo - Viale Porta Po, 88  Caratteristiche dell'impianto :", "Nuovo Polo Natatorio di Rovigo - Viale Porta Po, 88" ],
        [ "Le gare si svolgeranno presso la Piscina di Saronno,Via Cesare Miola 5, Saronno (VA).  Caratteristiche dell'impianto :", "di Saronno,Via Cesare Miola 5, Saronno (VA" ],
        [ "Le gare si svolgeranno nella nuova vasca da 50 metri della Piscina Comunale \"Carmen Longo\", (Stadio Comunale) Bologna, Via dello Sport.  Caratteristiche dell'impianto :", "Comunale \"Carmen Longo\", (Stadio Comunale) Bologna, Via dello Sport" ],
        [ "Le gare si svolgeranno presso la Piscina Piscina dell' Hotel Torre Artale, Contrada S. Onofrio, Trabia (Palermo).  Caratteristiche dell'impianto :", "Piscina dell' Hotel Torre Artale, Contrada S. Onofrio, Trabia (Palermo" ],
        [ "Le gare si svolgeranno presso la Piscina piscina olimpica del Villaggio Ge-Tur, in via centrale, 29 - 33054 Lignano Sabbiadoro (UD).  Caratteristiche dell'impianto :", "piscina olimpica del Villaggio Ge-Tur, in via centrale, 29 - 33054 Lignano Sabbiadoro (UD" ],
        [ "Le gare si svolgeranno presso la Piscina del “Centro Sportivo Manazzon” . Via Fogazzaro, 4 - Trento. Caratteristiche dell'impianto :", "del “Centro Sportivo Manazzon” . Via Fogazzaro, 4 - Trento" ],
        [ "Le gare si svolgeranno presso la Piscina del centro sportivo Zero9 sito in Roma, Via Cina n° 91 zona Torrino.  Caratteristiche dell'impianto :", "del centro sportivo Zero9 sito in Roma, Via Cina n° 91 zona Torrino" ],
        [ "Le gare si svolgeranno presso la Piscina Canottieri Vittorino da Feltre, Via del Pontiere, 29, Piacenza.  Caratteristiche dell'impianto :", "Canottieri Vittorino da Feltre, Via del Pontiere, 29, Piacenza" ],
        [ "Le gare si svolgeranno presso la Piscina del Villaggio Torre del Faro, Via Carlo Enrico Bernasconi, Scanzano Jonico.  Caratteristiche dell'impianto :", "del Villaggio Torre del Faro, Via Carlo Enrico Bernasconi, Scanzano Jonico" ],
        [ "Le gare si svolgeranno presso la Piscina del Centro Sportivo Italcementi di Bergamo – Via Statuto, 43 (zona ex-Ospedale).  Caratteristiche dell'impianto :", "del Centro Sportivo Italcementi di Bergamo – Via Statuto, 43 (zona ex-Ospedale" ],
        [ "Le gare si svolgeranno presso la Piscina Comunale di Gallarate (VA), Quartiere Moriggia Caratteristiche dell'impianto :", "Comunale di Gallarate (VA), Quartiere Moriggia" ],
        [ "Le gare si svolgeranno presso la Piscina delle Terme di Giunone, Via delle terme, 1, Caldiero Caratteristiche dell'impianto :", "delle Terme di Giunone, Via delle terme, 1, Caldiero" ],
        [ "Le gare si svolgeranno presso la Piscina dell' OTRE' WELLNESS CLUB sito in via Zona B39/F C.da Montedoro a Noci (BA).  Caratteristiche dell'impianto :", "dell' OTRE' WELLNESS CLUB sito in via Zona B39/F C.da Montedoro a Noci (BA" ],
        [ "Le gare si svolgeranno presso la Piscina del Centro Natatorio Comunale di Treviso Caratteristiche dell'impianto :", "del Centro Natatorio Comunale di Treviso" ],
        [ "Le gare si svolgeranno presso la Piscina del “Multieventi Sport Domus” di Serravalle, Repubblica di San Marino, Via Rancaglia 30.  Caratteristiche dell'impianto :", "del “Multieventi Sport Domus” di Serravalle, Repubblica di San Marino, Via Rancaglia 30" ],
        [ "Le gare si svolgeranno presso la Piscina Comunale Olimpica, via Rodi 20 Q.re Lamarmora Brescia.  Caratteristiche dell'impianto :", "Comunale Olimpica, via Rodi 20 Q.re Lamarmora Brescia" ],
        [ "Le gare si svolgeranno presso la Piscina Lido Azzurro viale Rebuzzini, 22 - Varedo MB.  Caratteristiche dell'impianto :", "Lido Azzurro viale Rebuzzini, 22 - Varedo MB" ],
        [ "Le gare si svolgeranno presso la Piscina comunale, palazzetto dello sport \"Emilio Zoli\", via della Costituzione, 37 - Pontedera. In caso di maltempo la gara verrà effettuata nella vasca coperta da 25 m. Caratteristiche dell'impianto :", "comunale, palazzetto dello sport \"Emilio Zoli\", via della Costituzione, 37 - Pontedera. In caso di maltempo la gara verrà effettuata nella vasca coperta da 25 m" ],
        [ "Le gare si svolgeranno presso la Piscina Comunale di Busto Garolfo, in via Busto Arsizio snc, angolo v.le Europa Caratteristiche dell'impianto :", "Comunale di Busto Garolfo, in via Busto Arsizio snc, angolo v.le Europa" ],
        [ "Le gare si svolgeranno presso la Piscina Comunale di Gioia del Colle (BA) sita in Via Salvator Rosa.  Caratteristiche dell'impianto :", "Comunale di Gioia del Colle (BA) sita in Via Salvator Rosa" ],
        [ "Le gare si svolgeranno presso la Piscina Olimpionica Terramaini di Cagliari.  Caratteristiche dell'impianto :", "Olimpionica Terramaini di Cagliari" ],
        [ "Le gare si svolgeranno presso la Piscina Comunale Palablù di Travagliato (Brescia), Via Montegrappa  Caratteristiche dell'impianto :", "Comunale Palablù di Travagliato (Brescia), Via Montegrappa" ],
        [ "Le gare si svolgeranno presso la Piscina del centro natatorio AQUANIENE The Sport Club sito in Roma, Viale della Moschea n° 130.  Caratteristiche dell'impianto :", "del centro natatorio AQUANIENE The Sport Club sito in Roma, Viale della Moschea n° 130" ],
        [ "Le gare si svolgeranno presso lo Sport Center di Priolo Gargallo, sito in Via Pirandello, 13.  Caratteristiche dell'impianto :", "Sport Center di Priolo Gargallo, sito in Via Pirandello, 13" ],
        [ "Le gare si svolgeranno presso la Piscina di Lovadina di Spresiano Via Gasparotto Vecellio 48/a.  Caratteristiche dell'impianto :", "di Lovadina di Spresiano Via Gasparotto Vecellio 48/a" ],
        [ "Le gare si svolgeranno presso la Piscina dell'Impianto Eugenio Dugoni, via Monte Grappa 8, Mantova.  Caratteristiche dell'impianto :", "dell'Impianto Eugenio Dugoni, via Monte Grappa 8, Mantova" ],
        [ "Le gare si svolgeranno presso la Piscina Comunale Il Grillo, contrada San Domenico 125/A Caratteristiche dell'impianto :", "Comunale Il Grillo, contrada San Domenico 125/A" ],
        [ "Le gare si svolgeranno presso la Piscina \"Faustina sporting club\" di Lodi viale Piermarini, Lodi.  Caratteristiche dell'impianto :", "\"Faustina sporting club\" di Lodi viale Piermarini, Lodi" ],
        [ "Le gare si svolgeranno presso la Piscina“La Bastia” Via Mastacchi 188 - Livorno.  Caratteristiche dell'impianto :", "La Bastia” Via Mastacchi 188 - Livorno" ]
      ].each do |pool_text, filtered_result|
        context "for the text ('#{pool_text}')," do
          it "is the expected result (#{filtered_result})" do
            expect( FinCalendarTextParser.get_filtered_pool_data_text(pool_text) ).to eq(filtered_result)
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.split_in_sentences()" do
      context "when splitting by default a phrase with sentence separators and NO quoted text but some contracted text," do
        it "splits the phrase for each separator found, ignoring the contraction quotes" do
          expect( FinCalendarTextParser.split_in_sentences(
            "London Bridge is falling down, fallin'down, fallin'down. London Bridge is falling down, my fair Lady."
          ) ).to eq(
            ["London Bridge is falling down", ",", "fallin'down", ",", "fallin'down", ".", "London Bridge is falling down", ",", "my fair Lady."]
          )
        end
      end

      context "when splitting by default a phrase with sentence separators and some single quoted text + some contracted text outside quotes," do
        it "splits the phrase for each separator found but leaving the quoted text as one" do
          expect( FinCalendarTextParser.split_in_sentences(
            "I'm singing 'London Bridge', but I'm out of tune."
          ) ).to eq(
            ["I'm singing 'London Bridge'", ",", "but I'm out of tune."]
          )
        end
      end

      context "when splitting by default a phrase with sentence separators and some actual quoted text," do
        it "splits the phrase for each separator, removes the quotes and leaves the quoted text as one" do
          expect( FinCalendarTextParser.split_in_sentences(
            "I'm singing \"London Bridge\", but I'm out of tune."
          ) ).to eq(
            ["I'm singing", "London Bridge", "", ",", "but I'm out of tune."]
          )
        end
      end

      context "when splitting with spaces a phrase with sentence separators and some actual quoted text," do
        it "splits the phrase for each space found, removes the quotes but splits also the quoted text" do
          expect( FinCalendarTextParser.split_in_sentences(
            "I'm singing \"London Bridge\", but I'm out of tune.", true # use space as "sentence" separator => apply more granularity
          ) ).to eq(
            ["I'm", "singing", "London", "Bridge", "but", "I'm", "out", "of", "tune."]
          )
        end
      end

      context "when splitting with spaces with some abbreviations," do
        it "splits the phrase for each non-word character found, respecting the abbreviated text (fixture #1)" do
          expect( FinCalendarTextParser.split_in_sentences(
            "Try with Km. 123, and Km.125: C.da Whatever #1, at St. Patrick or S. Patrick or S.Patrick.", true # use space as "sentence" separator => apply more granularity
          ) ).to eq(
            ["Try", "with", "Km.", "123", "and", "Km.125", "C.da", "Whatever", "1",
             "at", "St.", "Patrick", "or", "S.", "Patrick", "or", "S.Patrick."]
          )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.subtract_set_behaviour()" do
      context "when subtracting 2 sets with no intersection" do
        it "returns the same left array" do
          left_arr  = [1, 2, 3, 4, 5, 6]
          right_arr = [7, 8, 9, 10]
          expect(
            FinCalendarTextParser.subtract_set_behaviour( left_arr, right_arr )
          ).to eq( left_arr )
        end
      end


      context "when subtracting 2 sets with some intersection" do
        it "returns the left array minus the elements of the intersection" do
          left_arr  = [1, 2, 3, 4, 5, 6]
          right_arr = [2, 4, 6, 8, 10]
          expect(
            FinCalendarTextParser.subtract_set_behaviour( left_arr, right_arr )
          ).to eq( [1, 3, 5] )
        end
      end


      context "when subtracting 2 sets with some *partial* string matching" do
        it "returns the left array minus the all the matching substrings of the intersection (fixture #1)" do
          left_arr  = ["Presso lo \"Stadio del Nuoto\"", "via Atleti Azzurri, 25", "Firenze"]
          right_arr = ["Stadio", "Nuoto"]
          expect(
            FinCalendarTextParser.subtract_set_behaviour( left_arr, right_arr )
          ).to eq( ["Presso lo \" del \"", "via Atleti Azzurri, 25", "Firenze"] )
        end
        it "returns the left array minus the all the matching substrings of the intersection (fixture #2)" do
          left_arr  = ["Comunale G. Facci", "via Faccione, 1 Parma", "Italia"]
          right_arr = ["comunale", "facci"]
          expect(
            FinCalendarTextParser.subtract_set_behaviour( left_arr, right_arr )
          ).to eq( ["G.", "via Faccione, 1 Parma", "Italia"] )
        end
        it "returns the left array minus the all the matching substrings of the intersection (fixture #2)" do
          left_arr  = ["lariciumbala lilla", "lillallero lalilla"]
          right_arr = ["lilla"]
          expect(
            FinCalendarTextParser.subtract_set_behaviour( left_arr, right_arr )
          ).to eq( ["lariciumbala", "lillallero lalilla"] )
        end
        it "returns the left array minus the all the matching substrings of the intersection (fixture #2)" do
          left_arr  = ["via Staffoli,16"]
          right_arr = ["via", "Staffoli,16"]
          expect(
            FinCalendarTextParser.subtract_set_behaviour( left_arr, right_arr )
          ).to eq( [","] )
        end
        it "returns the left array minus the all the matching substrings of the intersection (fixture #2)" do
          left_arr  = ["Via porta Mondovì 7 Cuneo (CN"]
          right_arr = ["Via porta Mondovì 7"]
          expect(
            FinCalendarTextParser.subtract_set_behaviour( left_arr, right_arr )
          ).to eq( ["Cuneo (CN"] )
        end

      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.extract_possible_pool_definition" do
      prg = "Le gare si svolgeranno presso le Piscine \nDelfino Sport Center di Volla (NA), Via Alcide de Gasperi\n" +
            "Vasca coperta 25 mt, 8 corsie\nCronometraggio automatico\n\n" +
            "Centro Sportivo di Avellino, via S. Giorgio 76\nVasca coperta 25 mt, 10 corsie \nCronometraggio automatico \n\n\n" +
            "11 febbraio - sabato / Delfino Sport Center\n" +
            "ore 08.00 : Riscaldamento ore 08.45 : 200 FA - 1500 SL ( Massimo 64 iscritti )\n\n" +
            "12 febbraio - domenica / Centro Sportivo di Avellino\n" +
            "ore 08.00 : Riscaldamento ore 08.45 : 400sl - 200 Rana -100fa - 50 Do – MiStaff 4x50 mi\n" +
            "ore 14.30 : Riscaldamento ore 15.00 : 200sl – 200do – 200mx - MiStaff 4x50 sl\n\n"
      [
        [ prg, "11 febbraio - sabato / Delfino Sport Center", "Delfino Sport Center di Volla (NA), Via Alcide de Gasperi" ],
        [ prg, "ore 08.00 : Riscaldamento ore 08.45 : 200 FA - 1500 SL ( Massimo 64 iscritti )", nil ],
        [ prg, "12 febbraio - domenica / Centro Sportivo di Avellino", "Centro Sportivo di Avellino, via S. Giorgio 76" ],
        [ "Complesso piscine nuove di Reggio Emilia", "Complesso piscine nuove di Reggio Emilia", "Complesso piscine nuove di Reggio Emilia" ],
        [ "Piscina Stadio del Nuoto", "Piscina Stadio del Nuoto", "Piscina Stadio del Nuoto" ],
        [ "Piscina del Complesso Centro sportivo AquaFun", "Piscina del Complesso Centro sportivo AquaFun", "Piscina del Complesso Centro sportivo AquaFun" ],
        [ "Le gare si svolgeranno nella nuova vasca da 50 metri della Piscina Comunale", "Le gare si svolgeranno nella nuova vasca da 50 metri della Piscina Comunale", "Le gare si svolgeranno nella nuova vasca da 50 metri della Piscina Comunale" ],
        [ "Le gare si svolgeranno presso la Piscina comunale in Viale Ferrarin, 71 - Vicenza.  Caratteristiche dell'impianto :", "Le gare si svolgeranno presso la Piscina comunale in Viale Ferrarin, 71 - Vicenza.  Caratteristiche dell'impianto :", "Le gare si svolgeranno presso la Piscina comunale in Viale Ferrarin, 71 - Vicenza.  Caratteristiche dell'impianto :" ]
      ].each do |prg_text, curr_line, expected_result|
        context "for a valid text ('#{ curr_line }')," do
          it "is true" do
            expect(
              FinCalendarTextParser.extract_possible_pool_definition(prg_text, curr_line)
            ).to eq( expected_result )
          end
        end
      end

      [
        [ "vasca di riscaldamento", "vasca di riscaldamento" ],
        [ "8 corsie, 50 mt.", "8 corsie, 50 mt." ],
        [ "blablabla/blabla", "blablabla/blabla" ],
        [ "Le gare si svolgeranno presso le Piscine ", "Le gare si svolgeranno presso le Piscine " ]
      ].each do |prg_text, curr_line|
        context "for an invalid text ('#{ curr_line }')," do
          it "is false" do
            expect( FinCalendarTextParser.extract_possible_pool_definition(prg_text, curr_line) ).to be nil
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    # DEBUG specific cases:
    describe "self.event_line_token_splitter()" do
      it "splits fixture #1 correctly into tokens" do
        line = "ore 14.30 : Staff 4x50 MI F/M - 100 RA - 50 SL"
        token_list = FinCalendarTextParser.event_line_token_splitter( line )
        expect( token_list ).to eq(
          ["ore 14.30", "Staff 4x50 MI", "100 RA", "50 SL"]
        )
      end

      it "splits fixture #2 correctly into tokens" do
        line = "ore 08.00 : Riscaldamento ore 08.45 : 800 SL - 400 MI - 100 RA – 50 DO - 100 FA – 200 SL – 50 RA – 100MI – 50 FA                 MiStaff 4x50 SL - Staff  4 x 50 Mx "
        token_list = FinCalendarTextParser.event_line_token_splitter( line )
        expect( token_list ).to eq(
          [
            "ore 08.00", "Riscaldamento",
            "ore 08.45", "800 SL", "400 MI", "100 RA", "50 DO", "100 FA", "200 SL",
            "50 RA", "100MI", "50 FA", "MiStaff 4x50 SL", "Staff  4 x 50 Mx"
          ]
        )
      end

      it "splits fixture #3 correctly into tokens" do
        line = "ore 07.45 : Riscaldamento ore 08.45 : 100 DO - 50 SL - 100 MI - 20 min pausa per riscaldamento                  200 RA max 88 partecipanti - 50 FA - MiStaff  4x50 MI"
        token_list = FinCalendarTextParser.event_line_token_splitter( line )
        expect( token_list ).to eq(
          [
            "ore 07.45", "Riscaldamento",
            "ore 08.45", "100 DO", "50 SL", "100 MI", "riscaldamento",
            "200 RA", "50 FA", "MiStaff  4x50 MI"
          ]
        )
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.parse_pool_type" do
      context "for a program text containing a valid pool type description," do
        let(:program_text)    { "Vasca coperta 25 mt, 8 corsie\r\nCronometraggio manuale\r\nAltra vasca 33 mt sempre disponibile per riscaldamento" }
        let(:expected_value)  { PoolType.find_by_code("25") }
        it "returns the correct PoolType row" do
          expect(
            FinCalendarTextParser.parse_pool_type( program_text )
          ).to eq( expected_value )
        end
      end

      context "for a program text containing a semi-valid pool type description," do
        let(:program_text)    { "Vasca s coperta 50 mt, 8 corsie\r\nCronometraggio manuale" }
        let(:expected_value)  { PoolType.find_by_code("50") }
        it "returns the correct PoolType row" do
          expect(
            FinCalendarTextParser.parse_pool_type( program_text )
          ).to eq( expected_value )
        end
      end

      context "for a program text NOT containing a pool type description," do
        let(:program_text)    { "This is not a pool type (25 mt.) description" }
        it "returns nil" do
          expect(
            FinCalendarTextParser.parse_pool_type( program_text )
          ).to be nil
        end
      end
    end


    describe "self.parse_pool_lanes_number" do
      context "for a program text containing a valid pool lanes number description," do
        let(:program_text)    { "Vasca coperta 50 mt, 10 corsie\r\nCronometraggio manuale\r\nVasca 25 mt sempre disponibile per riscaldamento" }
        let(:expected_value)  { 10 }

        it "returns the correct tot. lanes value" do
          expect(
            FinCalendarTextParser.parse_pool_lanes_number( program_text )
          ).to eq( expected_value )
        end
      end

      context "for a program text NOT containing a valid pool lanes number description," do
        let(:program_text)    { "This is not a pool lanes total (10) description" }
        let(:default_value)   { 8 }

        it "returns the default tot. lanes value" do
          expect(
            FinCalendarTextParser.parse_pool_lanes_number( program_text )
          ).to eq( default_value )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#parse!" do
      context "for a valid meeting program sample," do
        let(:fixture_row) { FinCalendar.new( program_import_text: @fixture_list.sample ) }
        let(:parser)      { FinCalendarTextParser.new( fixture_row ) }

        it "updates the list of #session_daos (when it contains a date or a time)" do
          if FinCalendarTextParser.contains_a_date?( fixture_row.program_import_text ) ||
             FinCalendarTextParser.contains_a_time?( fixture_row.program_import_text )
            expect{ parser.parse!() }.to change{ parser.session_daos.count }
          end
        end

        # (See integration/strategies/fin_calendar_program_parsing_spec for more
        #  in-through examples)
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++


  context "with invalid parameters," do
    it "raises an ArgumentError" do
      expect{ FinCalendarTextParser.new }.to raise_error( ArgumentError )
      expect{ FinCalendarTextParser.new(nil) }.to raise_error( ArgumentError )
      expect{ FinCalendarTextParser.new(1) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
