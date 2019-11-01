require 'rails_helper'


describe FinCalendarMeetingBuilder, type: :strategy do

  let( :fixture_rows )          { FinCalendar.where( id: [1,2,4,5,6,7,8,10,13] ).to_a }
  let( :matching_meeting_ids )  { [ 16232, 16215, 16236, 16358, 16201, 16230, 16237, 16300, 16247 ] }
  let( :random_index )          { ( 0 .. fixture_rows.count-1 ).to_a.sample }
  let( :fin_calendar_row )      { fixture_rows[ random_index ] }
  let( :expected_meeting ) do
    rand_id = matching_meeting_ids[ random_index ]
# DEBUG
#    puts "\r\n- random idx: #{ random_index }, random Meeting ID: #{ rand_id }"
    meeting = Meeting.find( rand_id )
    expect( meeting ).to be_a( Meeting )
    meeting
  end
  #-- -------------------------------------------------------------------------
  #++


  context "with valid parameters," do
    subject { FinCalendarMeetingBuilder.new( User.find(1), fin_calendar_row ) }

    it_behaves_like( "(the existance of a method)", [
      :result_meeting, :report, :find_or_create!,
      :has_updated, :has_created, :has_errors, :has_changes?
    ] )

    it_behaves_like( "(the existance of a class method)", [
      :get_month_number, :get_iso_date, :parse_edition_and_type,
      :has_different_values?
    ] )
    #-- -----------------------------------------------------------------------
    #++


    describe "self.get_month_number()" do
      let(:months)            { ["gennaio", "febbraio", "marzo", "aprile", "maggio", "giugno", "luglio", "agosto", "settembre", "ottobre", "novembre", "dicembre"] }
      let(:random_month)      { months.sample }
      let(:random_int_month)  { (1..12).map{|i| i.to_s }.sample }

      context "for a valid month name," do
        it "is the expected ordinal value (1..12)" do
          expect( FinCalendarMeetingBuilder.get_month_number( random_month ) ).to eq( months.index( random_month ) + 1 )
        end
      end

      context "for an integer used as the month name," do
        it "is the expected ordinal value (1..12)" do
          expect( FinCalendarMeetingBuilder.get_month_number( random_int_month ) ).to eq( random_int_month.to_i )
        end
      end

      [
        "---", nil, ""
      ].each do |fixture_month|
        context "for an invalid month name," do
          it "is zero" do
            expect( FinCalendarMeetingBuilder.get_month_number( fixture_month ) ).to eq( 0 )
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.get_iso_date()" do
      let(:random_year)   { (rand * 100 % 20).to_i + 2000 }
      let(:months)        { ["gennaio", "febbraio", "marzo", "aprile", "maggio", "giugno", "luglio", "agosto", "settembre", "ottobre", "novembre", "dicembre"] }
      let(:random_month)  { months.sample }

      [
        "14", "31", "21-22", "03-05"
      ].each do |fixture_day|
        context "for a valid day text (#{ fixture_day })," do
          it "is a String" do
            expect(
              FinCalendarMeetingBuilder.get_iso_date(random_year, random_month, fixture_day)
            ).to be_a( String )
          end

          it "is properly formatted" do
            expect(
              FinCalendarMeetingBuilder.get_iso_date(random_year, random_month, fixture_day)
            ).to eq(
              "%04d-%02d-%02d" % [ random_year, months.index(random_month)+1, fixture_day.split(/\-/).first ]
            )
          end
        end
      end

      [
        "---", nil, ""
      ].each do |fixture_day|
        context "for an invalid day text ('#{ fixture_day }')," do
          it "is nil" do
            expect(
              FinCalendarMeetingBuilder.get_iso_date(random_year, "Gennaio", fixture_day)
            ).to be nil
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.parse_edition_and_type()" do
      [
        [ "16° Trofeo Città di Firenze", "Trofeo Città di Firenze", 16, EditionType::ROMAN_ID ],
        [ "XXIV Meeting Si Può Fare", "Meeting Si Può Fare", 24, EditionType::ROMAN_ID ],
        [ "1^ Trofeo Ginetto", "Trofeo Ginetto", 1, EditionType::ROMAN_ID ],
        [ "XVIII Trofeo della Montagna", "Trofeo della Montagna", 18, EditionType::ROMAN_ID ],

        [ "5a Prova Regionale CSI", "Prova Regionale CSI", 5, EditionType::SEASON_ID ],
        [ "2o Meeting Regionale UISP", "Meeting Regionale UISP", 2, EditionType::SEASON_ID ],

        [ "Distanze Speciali Em. Romagna", "Distanze Speciali Em. Romagna", nil, EditionType::YEAR_ID ],
        [ "Distanze speciali Lombardia", "Distanze speciali Lombardia", nil, EditionType::YEAR_ID ],
        [ "Regionali Liguria", "Regionali Liguria", nil, EditionType::YEAR_ID ],
        [ "Campionati Italiani FIN 2016", "Campionati Italiani FIN 2016", nil, EditionType::YEAR_ID ]
      ].each do |calendar_name, res_description, res_edition, res_edition_type_id|
        context "for a valid calendar_name ('#{ calendar_name }')," do
          it "returns the expected values" do
            description, edition, edition_type_id = FinCalendarMeetingBuilder.parse_edition_and_type( calendar_name )
            expect( description ).to eq( res_description )
            expect( edition ).to eq( res_edition )
            expect( edition_type_id ).to eq( res_edition_type_id )
          end
        end
      end

      [
        [ "---", "---", nil, EditionType::NONE_ID ],
        [ nil, nil, nil, EditionType::NONE_ID ],
        [ "", nil, nil, EditionType::NONE_ID ]
      ].each do |calendar_name, res_description, res_edition, res_edition_type_id|
        context "for an *invalid* calendar_name ('#{ calendar_name }')," do
          it "returns the expected values" do
            description, edition, edition_type_id = FinCalendarMeetingBuilder.parse_edition_and_type( calendar_name )
            expect( description ).to eq( res_description )
            expect( edition ).to eq( res_edition )
            expect( edition_type_id ).to eq( res_edition_type_id )
          end
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.has_different_values?()" do
      let(:random_meeting_read_only)  { meeting = Meeting.all.sample; meeting.do_not_update = true; meeting }
      let(:random_meeting_updatable)  { meeting = Meeting.all.sample; meeting.do_not_update = false; meeting }

      let(:code)            { random_meeting_updatable.code }
      let(:header_date)     { random_meeting_updatable.header_date }
      let(:header_year)     { random_meeting_updatable.header_year }
      let(:description)     { random_meeting_updatable.description }
      let(:edition)         { random_meeting_updatable.edition }
      let(:edition_type_id) { random_meeting_updatable.edition_type_id }
      let(:timing_type_id)  { random_meeting_updatable.timing_type_id }
      let(:is_confirmed)    { random_meeting_updatable.is_confirmed? }

      context "for a nil Meeting," do
        it "is false" do
          expect(
            FinCalendarMeetingBuilder.has_different_values?(
              nil,
              code, header_date, header_year, description,
              edition, edition_type_id, timing_type_id, is_confirmed,
              nil,
              nil
            )
          ).to be false
        end
      end

      context "for a valid, updatable Meeting compared w/ same values," do
        it "is false" do
          expect(
            FinCalendarMeetingBuilder.has_different_values?(
              random_meeting_updatable,
              code, header_date, header_year, description,
              edition, edition_type_id, timing_type_id, is_confirmed,
              random_meeting_updatable.entry_deadline,
              random_meeting_updatable.invitation
            )
          ).to be false
        end
      end

      context "for a valid, updatable Meeting compared w/ same values w/ numbers as strings," do
        it "is false" do
          expect(
            FinCalendarMeetingBuilder.has_different_values?(
              random_meeting_updatable,
              code, header_date, header_year, description,
              edition.to_s,
              edition_type_id.to_s,
              timing_type_id.to_s,
              is_confirmed,
              random_meeting_updatable.entry_deadline,
              random_meeting_updatable.invitation
            )
          ).to be false
        end
      end

      context "for a valid, updatable Meeting compared w/ DIFFERENT values," do
        it "is true" do
          expect(
            FinCalendarMeetingBuilder.has_different_values?(
              random_meeting_updatable,
              code, header_date, header_year, description,
              edition.to_i + 1,
              edition_type_id,
              timing_type_id,
              is_confirmed,
              random_meeting_updatable.entry_deadline,
              random_meeting_updatable.invitation
            )
          ).to be true
        end
      end

      context "for a valid READ-ONLY Meeting compared w/ DIFFERENT values," do
        it "is false" do
          expect(
            FinCalendarMeetingBuilder.has_different_values?(
              random_meeting_read_only,
              random_meeting_read_only.code, random_meeting_read_only.header_date,
              random_meeting_read_only.header_year, random_meeting_read_only.description,
              random_meeting_read_only.edition.to_i + 1,
              random_meeting_read_only.edition_type_id,
              random_meeting_read_only.timing_type_id,
              random_meeting_read_only.is_confirmed,
              random_meeting_read_only.entry_deadline,
              random_meeting_read_only.invitation
            )
          ).to be false
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#report" do
      subject { FinCalendarMeetingBuilder.new( User.find(1), fin_calendar_row ) }

      context "right from the start," do
        it "creates a log header" do
          output = []
          expect{ subject.report( output, :<< ) }.to change{ output }
        end
        it "includes the goggles_meeting_code in the process log" do
          output = []
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to include( fin_calendar_row.goggles_meeting_code )
        end
      end

      context "after a #find_or_create! call (with an existing Meeting)," do
        it "reports that the specified Meeting was found" do
          output = []
          subject.find_or_create!()
          # Make the end report:
          subject.report( output, :<< )
          expect( output.join("\r\n") ).to include( "Meeting found!" )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "#find_or_create!" do
      context "when called w/ a non-valid calendar row (w/ no goggles_meeting_code and no place)," do
        subject { FinCalendarMeetingBuilder.new( User.find(1), fin_calendar_incomplete ) }
        let(:fin_calendar_incomplete) { build(:fin_calendar, goggles_meeting_code: "", calendar_place: "-") }
        it "returns nil, w/o setting #has_errors" do
          subject.find_or_create!()
          expect( subject.result_meeting ).to be nil
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be false
        end
      end
      context "when called w/ a non-valid calendar row (w/ no goggles_meeting_code and no calendar_name)," do
        subject { FinCalendarMeetingBuilder.new( User.find(1), fin_calendar_incomplete ) }
        let(:fin_calendar_incomplete) { build(:fin_calendar, goggles_meeting_code: "", calendar_name: "") }
        it "returns nil, w/o setting #has_errors" do
          subject.find_or_create!()
          expect( subject.result_meeting ).to be nil
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be false
        end
      end


      context "when called for an existing Meeting (w/ perfect match)," do
        subject do
          FinCalendarMeetingBuilder.new( User.find(1), fin_calendar_row )
        end
        it "sets the #result_meeting member to the expected Meeting row & DOES NOT update the meeting" do
          # Let's make sure that we really have a fixture like that in the DB:
          expect( expected_meeting ).to be_a( Meeting )
          # Make the fixture and the expected meeting equal:
          description, edition, edition_type_id = FinCalendarMeetingBuilder.parse_edition_and_type( fin_calendar_row.calendar_name )
          expected_meeting.edition      = edition if edition.present?
          expected_meeting.description  = fin_calendar_row.calendar_name
          expected_meeting.header_year  = fin_calendar_row.season.header_year
          expected_meeting.edition_type_id = edition_type_id if edition_type_id.present?

          deadline_day, deadline_month, deadline_year = fin_calendar_row.name_import_text.to_s
            .split(/\:\s/ui).last.to_s.split("/")
          entry_deadline = "#{ deadline_year }-#{ deadline_month }-#{ deadline_day }"

          expected_meeting.entry_deadline = entry_deadline
          expected_meeting.invitation     = "https://www.federnuoto.it#{ fin_calendar_row.manifest_link }"
          expect( expected_meeting.save ).to be true

          subject.find_or_create!()
          expect( subject.result_meeting ).to be_a( Meeting )
          expect( subject.result_meeting.id ).to eq( expected_meeting.id )
# DEBUG
#          subject.report
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be false
        end
      end


      context "when called for an existing Meeting w/ slighly different code (but same city token in code)," do
        subject { FinCalendarMeetingBuilder.new( User.find(1), fin_calendar_row ) }
        let(:existing_meeting_with_wrong_code) do
          # Get the exact meeting linked to the fixture calendar row:
          # (Assuming all possible fixture rows are linked to existing meeting -- see above definition of fin_calendar_row)
# DEBUG
#          puts "\r\n- Code: '#{ fin_calendar_row.goggles_meeting_code }', fin_calendar row #{ fin_calendar_row.id }"
          expect( expected_meeting ).to be_a( Meeting )
          # Change the code:
          expected_meeting.code = "cittadi#{ fin_calendar_row.goggles_meeting_code }"
          expected_meeting.do_not_update = false
          expect( expected_meeting.save ).to be true
          expected_meeting
        end

        it "sets the #result_meeting member to the expected Meeting row and updates its code" do
          # Let's make sure that the meeting row was different before the call:
          expect( existing_meeting_with_wrong_code.code ).to eq( "cittadi#{ fin_calendar_row.goggles_meeting_code }" )
          subject.find_or_create!()
# DEBUG
#          subject.report
          expect( subject.result_meeting ).to be_a( Meeting )
          expect( subject.result_meeting.id ).to eq( existing_meeting_with_wrong_code.id )
          expect( subject.result_meeting.code ).to eq( fin_calendar_row.goggles_meeting_code )
          expect( subject.has_updated ).to be true
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be true
        end
      end


      context "when called for an existing Meeting w/ slighly different code (but same title token in code)," do
        let( :specific_row )      { FinCalendar.find(14) }
        let( :normalized_title )  { NameNormalizer.get_normalized_name( specific_row.calendar_name ) }
        subject { FinCalendarMeetingBuilder.new( User.find(1), specific_row ) }
        let(:existing_meeting_with_wrong_code) do
          # Get the exact meeting linked to the fixture calendar row:
          # (Assuming all possible fixture rows are linked to existing meeting -- see above definition of fin_calendar_row)
          meeting = Meeting.find(16246)
          expect( meeting ).to be_a( Meeting )
          # Change the code:
          meeting.code = "unaltracitta#{ normalized_title }"
          meeting.do_not_update = false
          expect( meeting.save ).to be true
          meeting
        end

        it "sets the #result_meeting member to the expected Meeting row and updates its code" do
          # Let's make sure that the meeting row was different before the call:
          expect( existing_meeting_with_wrong_code.code ).to eq( "unaltracitta#{ normalized_title }" )
          subject.find_or_create!()
          expect( subject.result_meeting ).to be_a( Meeting )
          expect( subject.result_meeting.id ).to eq( existing_meeting_with_wrong_code.id )
          expect( subject.result_meeting.code ).to eq( specific_row.goggles_meeting_code )
          expect( subject.has_updated ).to be true
          expect( subject.has_created ).to be false
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be true
        end
      end


      context "when called for a NOT-yet existing Meeting," do
        let( :fin_calendar_row )  { create(:fin_calendar, calendar_place: FFaker::Address.city) }
        subject { FinCalendarMeetingBuilder.new( User.find(1), fin_calendar_row ) }
        let(:result) do
          # Let's make sure that the fixture's Meeting doesn't exist in the DB:
          expect( Meeting.where(season_id: fin_calendar_row.season_id, code: fin_calendar_row.goggles_meeting_code).count ).to eq(0)
          subject.find_or_create!()
        end

        it "returns a Meeting instance and sets has_created to true" do
          expect( result ).to be_a( Meeting )
          expect( subject.has_updated ).to be false
          expect( subject.has_created ).to be true
          expect( subject.has_errors ).to be false
          expect( subject.has_changes? ).to be true
        end
        it "creates a new Meeting with the expected new code" do
          expect( result.code ).to eq( fin_calendar_row.goggles_meeting_code )
          expect( result.id ).to be > 0
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
      expect{ FinCalendarMeetingBuilder.new }.to raise_error( ArgumentError )
      expect{ FinCalendarMeetingBuilder.new(nil, nil) }.to raise_error( ArgumentError )
      expect{ FinCalendarMeetingBuilder.new(1, nil) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
