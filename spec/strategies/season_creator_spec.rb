require 'rails_helper'


describe SeasonCreator, type: :strategy do

  context "with non-valid parameters," do
    it "raises an exception for wrong season parameter" do
      expect{ SeasonCreator.new }.to raise_error( ArgumentError )
      expect{ SeasonCreator.new( 'only such description' ) }.to raise_error( ArgumentError )
      expect{ SeasonCreator.new( Season.all.limit(100).sort{0.5 - rand}[0] ) }.to raise_error( ArgumentError )
      # TODO [Steve, 20160917] This is not true anymore: (free ID helper-finder added)
#      expect{ SeasonCreator.new( Season.find(131), 'damn, that season was already duplicated' ) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  context "with valid parameters," do
    # Needs a UNIQUE season
    let(:older_season)    { SeasonType.find_by_code('MASCSI').seasons.last }
    let(:older_season_id) { older_season.id }
    let(:description)     { "#{FFaker::Lorem.word}-maybe#{ older_season_id + rand * 100}" }

    subject { SeasonCreator.new( older_season, description ) }

    it_behaves_like( "(the existance of a method)", [
      :description,
      :new_id, :begin_date, :end_date, :header_year, :edition,
      :categories, :meetings, :meeting_sessions, :meeting_events,
      :renew_season, :renew_categories, :renew_meetings
    ] )

    describe "#parameters," do
      it "are the given parameters" do
        expect( subject.older_season ).to eq( older_season )
        expect( subject.description ).to eq( description )
      end
    end

    describe "#new_id," do
      it "is a valid number" do
        expect( subject.new_id ).to be > 0
      end
      # FIXME/REMOVE Too much implementation detail. Not good. Moreover, this may not always be true
#      it "is 10 greater than older season id" do
#        expect( subject.new_id ).to eq( newer_season_id )
#      end
    end
    describe "#begin_date," do
      it "is a valid date" do
        expect( subject.begin_date ).to be_a_kind_of( Date )
      end
      it "is one year older than older season begin date" do
        expect( subject.begin_date ).to eq( subject.older_season.begin_date.next_year )
      end
    end
    describe "#end_date," do
      it "is a valid date" do
        expect( subject.end_date ).to be_a_kind_of( Date )
      end
      it "is one year older than older season end date" do
        expect( subject.end_date ).to eq( subject.older_season.end_date.next_year )
      end
    end
    describe "#header_year," do
      it "is a valid string" do
        expect( subject.header_year ).to be_a_kind_of( String )
      end
    end
    describe "#edition," do
      it "is a valid number" do
        expect( subject.edition ).to be >= 0
      end
      it "is greater than older season one" do
        expect( subject.edition ).to be > subject.older_season.edition
      end
    end
    #-- -----------------------------------------------------------------------
    #++


    describe "self.next_header_year," do
      it "returns a valid string" do
        expect( subject.class.next_header_year( subject.older_season.header_year ) ).to be_a_kind_of( String )
      end
      it "returns a string representing a greater value if simple year given" do
        simple_year = 2000 + (rand * 25).to_i
        expect( subject.class.next_header_year( simple_year.to_s ) ).to be_a_kind_of( String )
        expect( subject.class.next_header_year( simple_year.to_s ).to_i ).to be > simple_year
      end
      it "returns a string representing a greater couple of year if couple of year given" do
        year = 2000 + ( rand * 25 ).to_i
        couple_year = year.to_s + '/' + ( year + 1 ).to_s
        next_couple_year = subject.class.next_header_year( couple_year )
        expect( next_couple_year ).to be_a_kind_of( String )
        expect( next_couple_year.length ).to eq( 9 )
        years = next_couple_year.split('/')
        expect( years.size ).to eq( 2 )
        expect( years[0].to_i ).to be < years[1].to_i
        expect( years[0].to_i ).to eq( year + 1 )
        expect( years[1].to_i ).to eq( year + 2 )
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "self.next_year_eq_day," do
      it "returns a valid date" do
        fix_date = ( Date.today - ((rand * 365) % 365).to_i )
        expect( subject.class.next_year_eq_day( fix_date ) ).to be_a_kind_of( Date )
      end
      it "returns a date greater than given one" do
        fix_date = ( Date.today - ((rand * 365) % 365).to_i )
        expect( subject.class.next_year_eq_day( fix_date ) ).to be > fix_date
      end
      it "returns a date with the same day of week of given one" do
        fix_date = ( Date.today - ((rand * 365) % 365).to_i )
        expect( subject.class.next_year_eq_day( fix_date ).wday ).to eq( fix_date.wday )
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#prepare_new_season," do
    # Needs a UNIQUE season
    let(:older_season)    { SeasonType.find_by_code('MASCSI').seasons.last }
    let(:older_season_id) { older_season.id }
    let(:description)     { "#{FFaker::Lorem.word}-maybe#{ older_season_id + rand * 100}" }

    subject { SeasonCreator.new( older_season, description ) }

    it "returns season, meetings and so on" do
      expect( subject.new_season ).to be_nil
      expect( subject.meetings.count ).to eq(0)
      expect( subject.meeting_sessions.count ).to eq(0)
      expect( subject.meeting_events.count ).to eq(0)
      subject.prepare_new_season
      expect( subject.new_season ).to be_an_instance_of( Season )
      expect( subject.categories ).to all(be_an_instance_of( CategoryType ))
      expect( subject.meetings ).to all(be_an_instance_of( Meeting ))
      expect( subject.meeting_sessions ).to all(be_an_instance_of( MeetingSession ))
      expect( subject.meeting_events ).to all(be_an_instance_of( MeetingEvent ))
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#renew_season," do
    # Needs a UNIQUE season
    let(:older_season)    { SeasonType.find_by_code('MASCSI').seasons.last }
    let(:older_season_id) { older_season.id }
    let(:description)     { "#{FFaker::Lorem.word}-maybe#{ older_season_id + rand * 100}" }

    subject { SeasonCreator.new( older_season, description ).renew_season }

    it "returns a valid season" do
      expect( subject ).to be_an_instance_of( Season )
      expect( subject ).to be_valid
    end
    it "returns a persisted season" do
      expect( Season.exists?( subject.id ) ).to be true
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#new_season," do
    # Needs a UNIQUE season
    let(:older_season)    { SeasonType.find_by_code('MASCSI').seasons.last }
    let(:older_season_id) { older_season.id }
    let(:description)     { "#{FFaker::Lorem.word}-maybe#{ older_season_id + rand * 100}" }

    subject { SeasonCreator.new( older_season, description ) }

    it "is a valid season" do
      new_season = subject.renew_season
      expect( new_season ).to be_an_instance_of( Season )
    end
    it "has the calculated id" do
      new_season = subject.renew_season
      expect( new_season.id ).to eq( subject.new_id )
    end
    it "has the given description" do
      new_season = subject.renew_season
      expect( new_season.description ).to eq( subject.description )
    end
    it "has the calculated begin date" do
      new_season = subject.renew_season
      expect( new_season.begin_date ).to eq( subject.begin_date )
    end
    it "has the calculated end date" do
      new_season = subject.renew_season
      expect( new_season.end_date ).to eq( subject.end_date )
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#renew_categories," do
    # Needs a UNIQUE season
    let(:older_season)    { SeasonType.find_by_code('MASCSI').seasons.last }
    let(:older_season_id) { older_season.id }
    let(:description)     { "#{FFaker::Lorem.word}-maybe#{ older_season_id + rand * 100}" }
    let(:creator)         { SeasonCreator.new( older_season, description ) }

    subject do
      creator.prepare_new_season
      creator.categories
    end

    it "returns a collection of category types" do
      expect( subject ).to be_a_kind_of( Array )
      expect( subject ).to all(be_an_instance_of( CategoryType ))
    end
    it "returns a collection of category types associated to the new season" do
      subject.each do |category_type|
        expect( category_type.season_id ).to eq( creator.new_season.id )
      end
    end
    it "returns the same number and types of categories of the older season" do
      expect( subject.count ).to eq( older_season.category_types.count )
    end
    it "returns the same category types code of older season" do
      subject.each do |category_type|
        expect( older_season.category_types.find_by_code( category_type.code )).to be_an_instance_of( CategoryType )
      end
    end
    it "persists the new categories" do
      expect( subject.count ).to eq( older_season.category_types.count )
    end

    describe "#categories," do
      it "is a collection of categories" do
        expect( subject ).to be_a_kind_of( Array )
        expect( subject ).to all(be_an_instance_of( CategoryType ))
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  describe "#renew_meetings," do
    # Needs a UNIQUE season
    let(:older_season)    { SeasonType.find_by_code('MASCSI').seasons.last }
    let(:older_season_id) { older_season.id }
    let(:description)     { "#{FFaker::Lorem.word}-maybe#{ older_season_id + rand * 100}" }
    let(:creator)         { SeasonCreator.new( older_season, description ) }

    subject do
      creator.prepare_new_season
      creator.meetings
    end

    it "returns a collection of meetings" do
      expect( subject ).to be_a_kind_of( Array )
      expect( subject ).to all(be_an_instance_of( Meeting ))
    end
    it "returns a collection of meetings associated to the new season" do
      subject.each do |meeting|
        expect( meeting.season_id ).to eq( creator.new_season.id )
      end
    end
    it "returns the same number of meetings of the older season" do
      expect( subject.count ).to eq( older_season.meetings.count )
    end
    it "returns meetings with the given default values" do
      subject.each do |meeting|
        expect( meeting.are_results_acquired ).to eq( false )
        expect( meeting.is_autofilled ).to eq( true )
        expect( meeting.has_start_list ).to eq( false )
        expect( meeting.has_invitation ).to eq( false )
        expect( meeting.invitation ).to eq( nil )
        expect( meeting.is_confirmed ).to eq( false )
      end
    end
    it "persists the new meetings" do
      subject
      expect( Season.find( creator.new_season.id ).meetings.count ).to eq( older_season.meetings.count )
    end
    it "persists the new meeting sessions" do
      subject
      expect( Season.find( creator.new_season.id ).meetings.count ).to eq( older_season.meetings.count )
    end

    describe "#meetings," do
      it "is a collection of meetings" do
        expect( subject ).to be_a_kind_of( Array )
        expect( subject ).to all(be_an_instance_of( Meeting ))
      end
    end

    describe "#meeting_sessions," do
      it "is a collection of meeting_sessions" do
        expect( creator.meeting_sessions ).to be_a_kind_of( Array )
        expect( creator.meeting_sessions ).to all(be_an_instance_of( MeetingSession ))
      end
    end

    describe "#meeting_events," do
      it "is a collection of meeting_events" do
        expect( creator.meeting_events ).to be_a_kind_of( Array )
        expect( creator.meeting_events ).to all(be_an_instance_of( MeetingEvent ))
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
