require 'rails_helper'
require 'wrappers/timing'


describe SwimmerBestFinder, type: :strategy do

  context "with requested parameters" do
    let(:csi_season_type) { SeasonType.find_by_code('MASCSI') }
    let(:csi_season)      { csi_season_type.seasons.is_ended.order('RAND()').first }
    let(:active_swimmer) do
      ( team = csi_season.teams.order('RAND()').first ) while team.nil?
      team.badges.for_season( csi_season ).order('RAND()').first.swimmer
    end
    let(:active_team) { active_swimmer.team }

    subject { SwimmerBestFinder.new( active_swimmer ) }

    it_behaves_like( "(the existance of a method)", [
      :swimmer
    ] )

    describe "#parameters," do
      it "are the given parameters" do
        expect( subject.swimmer ).to eq( active_swimmer )
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_closed_seasons_involved_into, " do
      it "returns an array" do
        expect( subject.get_closed_seasons_involved_into ).to be_a_kind_of( ActiveRecord::Relation )
      end
      it "returns an array of seasons" do
        expect( subject.get_closed_seasons_involved_into ).to all(be_an_instance_of( Season ))
      end
      it "returns an array of ended seasons" do
        subject.get_closed_seasons_involved_into.each do |season|
          expect( season.is_season_ended_at ).to be true
        end
      end
      it "returns an array of sorted seasons" do
        seasons = subject.get_closed_seasons_involved_into
        elem = 1
        while elem < seasons.size do
          expect( seasons[elem].begin_date ).to be <= seasons[elem - 1].begin_date
          elem = elem + 1
        end
      end
      it "returns an array of seasons of given season type" do
        subject.get_closed_seasons_involved_into( csi_season_type ).each do |season|
          expect( season.season_type.code ).to eq( csi_season_type.code )
        end
      end
      it "returns an array of seasons same season type if given" do
        expect( subject.get_closed_seasons_involved_into( csi_season_type ).map{ |s| s.season_type.code }.uniq.count ).to eq( 1 )
      end
      it "returns an array of seasons of different season types if any" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        expect( fix_sbf.get_closed_seasons_involved_into.map{ |s| s.season_type.code }.uniq.count ).to be > 1
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_current_seasons_involved_into, " do
      it "returns an array" do
        expect( subject.get_current_seasons_involved_into ).to be_a_kind_of( ActiveRecord::Relation )
      end
      it "returns an array of seasons" do
        expect( subject.get_current_seasons_involved_into ).to all(be_an_instance_of( Season ))
      end
      it "returns an array of not ended seasons" do
        subject.get_current_seasons_involved_into.each do |season|
          expect( season.is_season_ended_at ).to be false
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_contemporary_seasons_involved_into, " do
      it "returns an array" do
        expect( subject.get_contemporary_seasons_involved_into( csi_season ) ).to be_a_kind_of( ActiveRecord::Relation )
      end
      it "returns an array of seasons" do
        expect( subject.get_contemporary_seasons_involved_into( csi_season ) ).to all(be_an_instance_of( Season ))
      end
      it "returns an array of seasons conteporary of given one" do
        subject.get_contemporary_seasons_involved_into( csi_season ).each do |season|
          expect( season.begin_date ).to be <= csi_season.end_date
          expect( season.end_date ).to be >= csi_season.begin_date
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_involved_season_last_best_for_event," do
      it "returns a timing instance if event already swam" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('50FA')
        fix_pool    = PoolType.find_by_code('25')
        expect( fix_sbf.get_involved_season_last_best_for_event( fix_sbf.get_closed_seasons_involved_into, fix_event, fix_pool ) ).to be_an_instance_of( Timing )
      end
      it "returns nil if event not already swam" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('100MI')
        fix_pool    = PoolType.find_by_code('50')
        expect( fix_sbf.get_involved_season_last_best_for_event( fix_sbf.get_closed_seasons_involved_into, fix_event, fix_pool ) ).to be_nil
      end
      it "returns nil if event not already swam in the correct season type" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('200FA')
        fix_pool    = PoolType.find_by_code('25')
        expect( fix_sbf.get_involved_season_last_best_for_event( fix_sbf.get_closed_seasons_involved_into( csi_season_type ), fix_event, fix_pool ) ).to be_nil
      end
      it "returns a time swam in the past season if any" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('200MI')
        fix_pool    = PoolType.find_by_code('25')
        fix_seasons = csi_season_type.seasons.is_ended_before( Date.new(2015, 11, 15) ).sort_season_by_begin_date('DESC')
        expect( fix_swimmer.meeting_individual_results.is_not_disqualified.for_season( fix_seasons.first ).for_pool_type( fix_pool ).for_event_type( fix_event ).count ).to be > 0
        expect( fix_sbf.get_involved_season_last_best_for_event( fix_seasons, fix_event, fix_pool ) ).to eq( fix_swimmer.meeting_individual_results.is_not_disqualified.for_season( fix_seasons.first ).for_pool_type( fix_pool ).for_event_type( fix_event ).sort_by_timing('ASC').first.get_timing_instance )
      end
      it "returns a time swam in an older season if not swimmed in the past one" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('400MI')
        fix_pool    = PoolType.find_by_code('50')
        fix_seasons = csi_season_type.seasons.is_ended_before( Date.new(2015, 11, 15) ).sort_season_by_begin_date('DESC')
        expect( fix_swimmer.meeting_individual_results.is_not_disqualified.for_season( fix_seasons.first ).for_pool_type( fix_pool ).for_event_type( fix_event ).count ).to eq( 0 )
        expect( fix_sbf.get_involved_season_last_best_for_event( fix_seasons, fix_event, fix_pool ) ).to be_an_instance_of( Timing )
      end
      it "returns a time swam if swam before or nil if not" do
        event = EventsByPoolType.not_relays.order('RAND()').first
        if active_swimmer.meeting_individual_results.is_not_disqualified.for_closed_seasons.for_pool_type( event.pool_type ).for_event_type( event.event_type ).count > 0
          expect( subject.get_involved_season_last_best_for_event( subject.get_closed_seasons_involved_into, event.event_type, event.pool_type ) ).to be_an_instance_of( Timing )
        else
          expect( subject.get_involved_season_last_best_for_event( subject.get_closed_seasons_involved_into, event.event_type, event.pool_type ) ).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_involved_season_best_for_event," do
      it "returns a timing instance if event already swam" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('50FA')
        fix_pool    = PoolType.find_by_code('25')
        expect( fix_sbf.get_involved_season_best_for_event( fix_sbf.get_contemporary_seasons_involved_into( Season.find(141) ), fix_event, fix_pool ) ).to be_an_instance_of( Timing )
      end
      it "returns nil if event not already swam" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('100MI')
        fix_pool    = PoolType.find_by_code('50')
        expect( fix_sbf.get_involved_season_best_for_event( fix_sbf.get_contemporary_seasons_involved_into( Season.find( 141 ) ), fix_event, fix_pool ) ).to be_nil
      end
      it "returns nil if event not already swam in the seasons" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('200FA')
        fix_pool    = PoolType.find_by_code('25')
        expect( fix_sbf.get_involved_season_best_for_event( fix_sbf.get_closed_seasons_involved_into( csi_season_type ), fix_event, fix_pool ) ).to be_nil
      end
      it "returns a time swam if swam before or nil if not" do
        event = EventsByPoolType.not_relays.order('RAND()').first
        if active_swimmer.meeting_individual_results.is_not_disqualified.for_season( csi_season ).for_pool_type( event.pool_type ).for_event_type( event.event_type ).count > 0
          expect( subject.get_involved_season_best_for_event( subject.get_contemporary_seasons_involved_into( csi_season ), event.event_type, event.pool_type ) ).to be_an_instance_of( Timing )
        else
          expect( subject.get_involved_season_best_for_event( subject.get_contemporary_seasons_involved_into( csi_season ), event.event_type, event.pool_type ) ).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_involved_season_last_best_for_key," do
      it "returns a time swam if swam before or nil if not" do
        event = EventsByPoolType.not_relays.order('RAND()').first
        if active_swimmer.meeting_individual_results.is_not_disqualified.for_closed_seasons.for_pool_type( event.pool_type ).for_event_type( event.event_type ).count > 0
          expect( subject.get_involved_season_last_best_for_key( subject.get_closed_seasons_involved_into, event.get_key ) ).to be_an_instance_of( Timing )
        else
          expect( subject.get_involved_season_last_best_for_key( subject.get_closed_seasons_involved_into, event.get_key ) ).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_season_type_best_for_event," do
      it "returns a timing instance if event already swam" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('50FA')
        fix_pool    = PoolType.find_by_code('25')
        expect( fix_sbf.get_season_type_best_for_event( csi_season_type, fix_event, fix_pool ) ).to be_an_instance_of( Timing )
      end
      it "returns nil if event not already swam" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('100MI')
        fix_pool    = PoolType.find_by_code('50')
        expect( fix_sbf.get_season_type_best_for_event( csi_season_type, fix_event, fix_pool ) ).to be_nil
      end
      it "returns a time swam if swam before or nil if not" do
        event = EventsByPoolType.not_relays.order('RAND()').first
        if active_swimmer.meeting_individual_results.is_not_disqualified.for_season_type( csi_season_type ).for_pool_type( event.pool_type ).for_event_type( event.event_type ).count > 0
          expect( subject.get_season_type_best_for_event( csi_season_type, event.event_type, event.pool_type ) ).to be_an_instance_of( Timing )
        else
          expect( subject.get_season_type_best_for_event( csi_season_type, event.event_type, event.pool_type ) ).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_best_for_event," do
      it "returns a timing instance if event already swam" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('50FA')
        fix_pool    = PoolType.find_by_code('25')
        expect( fix_sbf.get_best_for_event( fix_event, fix_pool ) ).to be_an_instance_of( Timing )
      end
      it "returns nil if event not already swam" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_event   = EventType.find_by_code('100MI')
        fix_pool    = PoolType.find_by_code('50')
        expect( fix_sbf.get_best_for_event( fix_event, fix_pool ) ).to be_nil
      end
      it "returns a time swam if swam before or nil if not" do
        event = EventsByPoolType.not_relays.order('RAND()').first
        if active_swimmer.meeting_individual_results.is_not_disqualified.for_pool_type( event.pool_type ).for_event_type( event.event_type ).count > 0
          expect( subject.get_best_for_event( event.event_type, event.pool_type ) ).to be_an_instance_of( Timing )
        else
          expect( subject.get_best_for_event( event.event_type, event.pool_type ) ).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_best_for_event_result," do
      it "returns a meeting individual result" do
        fix_swimmer            = Swimmer.find(23)
        fix_sbf                = SwimmerBestFinder.new( fix_swimmer )
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        fix_sbf.set_personal_best( fix_event_by_pool_type )
        expect( fix_sbf.get_best_for_event_result( fix_event_by_pool_type.event_type, fix_event_by_pool_type.pool_type ) ).to be_an_instance_of( MeetingIndividualResult )
      end
    end
    #-- -----------------------------------------------------------------------

    # Test this feature with real data for praticity
    # Sure that Leega swam 25FA more than two times in 25 pool
    # and has been disqualified at least one time in 100MI (huncle dog)
    describe "#is_personal_best," do
      it "returns a boolean" do
        result = active_swimmer.meeting_individual_results.order('RAND()').first
        expect( subject.is_personal_best( result ) ).to eq( true ).or( eq( false ) )
      end
      it "returns true if personal best" do
        fix_swimmer            = Swimmer.find(23)
        fix_sbf                = SwimmerBestFinder.new( fix_swimmer )
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        fix_sbf.set_personal_best( fix_event_by_pool_type )
        best_result = fix_sbf.get_best_for_event_result( fix_event_by_pool_type.event_type, fix_event_by_pool_type.pool_type )
        expect( fix_sbf.is_personal_best( best_result ) ).to eq( true )
      end
      it "returns false if not personal best" do
        fix_swimmer            = Swimmer.find(23)
        fix_sbf                = SwimmerBestFinder.new( fix_swimmer )
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        worst_result           = fix_swimmer.meeting_individual_results.for_event_by_pool_type( fix_event_by_pool_type ).sort_by_timing('DESC').first 
        expect( fix_sbf.is_personal_best( worst_result ) ).to eq( false )
      end
      it "returns false if disqualified" do
        fix_swimmer            = Swimmer.find(23)
        fix_sbf                = SwimmerBestFinder.new( fix_swimmer )
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '100MI')
        disqualified_result    = fix_swimmer.meeting_individual_results.for_event_by_pool_type( fix_event_by_pool_type ).is_disqualified.first 
        expect( fix_sbf.is_personal_best( disqualified_result ) ).to eq( false )
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_best_for_meeting_event," do
      it "returns a timing instance if event already swam" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_meeting = Meeting.find(14201)
        fix_event   = EventType.find_by_code('50FA')
        fix_pool    = PoolType.find_by_code('25')
        expect( fix_sbf.get_best_for_meeting_event( fix_meeting, fix_event, fix_pool ) ).to be_an_instance_of( Timing )
      end
      it "returns nil if event not already swam" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        fix_meeting = Meeting.find(14201)
        fix_event   = EventType.find_by_code('100MI')
        fix_pool    = PoolType.find_by_code('50')
        expect( fix_sbf.get_best_for_meeting_event( fix_meeting, fix_event, fix_pool ) ).to be_nil
      end
      it "returns a time swam if swam before or nil if not" do
        event = EventsByPoolType.not_relays.order('RAND()').first
        meeting = csi_season.meetings.order('RAND()').first
        if active_swimmer.meeting_individual_results.is_not_disqualified.for_meeting_editions( meeting ).for_pool_type( event.pool_type ).for_event_type( event.event_type ).count > 0
          expect( subject.get_best_for_meeting_event( meeting, event.event_type, event.pool_type ) ).to be_an_instance_of( Timing )
        else
          expect( subject.get_best_for_meeting_event( meeting, event.event_type, event.pool_type ) ).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#reset_personal_best," do
      it "clears personal best" do
        fix_swimmer            = Swimmer.find(23)
        fix_sbf                = SwimmerBestFinder.new( fix_swimmer )
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        fix_sbf.reset_personal_best( fix_event_by_pool_type )
        expect( fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).is_personal_best.count ).to eq( 0 )
      end
      it "clears personal best already set" do
        fix_swimmer            = Swimmer.find(23)
        fix_sbf                = SwimmerBestFinder.new( fix_swimmer )
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        fix_sbf.set_personal_best( fix_event_by_pool_type )
        expect( fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).is_personal_best.count ).to be > 0
        fix_sbf.reset_personal_best( fix_event_by_pool_type )
        expect( fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).is_personal_best.count ).to eq( 0 )
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#reset_all_personal_bests," do
      it "clears personal best already set" do
        subject.scan_for_personal_bests
        subject.reset_all_personal_bests
        expect( active_swimmer.meeting_individual_results.is_personal_best.count ).to eq( 0 )
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#set_personal_best," do
      it "returns a timing instance if event already swam" do
        fix_swimmer            = Swimmer.find(23)
        fix_sbf                = SwimmerBestFinder.new( fix_swimmer )
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        expect( fix_sbf.set_personal_best( fix_event_by_pool_type ) ).to be_an_instance_of( Timing )
      end
      it "sets personal best flag if event already swam" do
        fix_swimmer            = Swimmer.find(23)
        fix_sbf                = SwimmerBestFinder.new( fix_swimmer )
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '50FA')
        fix_sbf.reset_personal_best( fix_event_by_pool_type )
        expect( fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).is_personal_best.count ).to eq( 0 )
        fix_sbf.set_personal_best( fix_event_by_pool_type )
        expect( fix_swimmer.meeting_individual_results.for_event_by_pool_type(fix_event_by_pool_type).is_personal_best.count ).to be > 0
      end
      it "sets a time corresponding to the best swam (if swam)" do
        event = EventsByPoolType.not_relays.order('RAND()').first
        if active_swimmer.meeting_individual_results.for_event_by_pool_type( event ).is_not_disqualified.count > 0
          expect( subject.set_personal_best( event ) ).to eq( subject.get_best_for_event( event.event_type, event.pool_type ) )
          expect( subject.set_personal_best( event ) ).to eq( active_swimmer.meeting_individual_results.for_event_by_pool_type( event ).is_not_disqualified.sort_by_timing( :asc ).first.get_timing_instance )
        else
          expect( subject.set_personal_best( event ) ).to eq( subject.get_best_for_event( event.event_type, event.pool_type ) )
        end
      end
      # Assumes Leega didn't ever swam 3000 in 25 pool.
      # If he will swim it... not change the spec, but, please, heal Leega
      it "returns nil if event not already swam" do
        fix_swimmer            = Swimmer.find(23)
        fix_sbf                = SwimmerBestFinder.new( fix_swimmer )
        fix_event_by_pool_type = EventsByPoolType.find_by_pool_and_event_codes('25', '3000SL')
        expect( fix_sbf.set_personal_best( fix_event_by_pool_type ) ).to be_nil
      end
      it "returns a time swam if swam before or nil if not" do
        event = EventsByPoolType.not_relays.order('RAND()').first
        if active_swimmer.meeting_individual_results.for_event_by_pool_type( event ).is_not_disqualified.count > 0
          expect( subject.set_personal_best( event ) ).to be_an_instance_of( Timing )
          expect( active_swimmer.meeting_individual_results.for_event_by_pool_type( event ).is_personal_best.count ).to be > 0
        else
          expect( subject.set_personal_best( event ) ).to be nil
        end
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#scan_for_personal_bests," do
      it "sets at least 20 personal bests for Leega" do
        fix_swimmer = Swimmer.find(23)
        fix_sbf     = SwimmerBestFinder.new( fix_swimmer )
        expect( fix_sbf.scan_for_personal_bests ).to be >= 20
      end
      it "returns 0 for swimmer without results" do
        new_swimmer = create( :swimmer )
        fix_sbf     = SwimmerBestFinder.new( new_swimmer )
        expect( fix_sbf.scan_for_personal_bests ).to eq( 0 )
      end
      it "sets a personal best for each event by pool type swam by swimmer" do
        event_swam = 0
        subject.scan_for_personal_bests
        EventsByPoolType.not_relays.each do |event_by_pool_type|
          if active_swimmer.meeting_individual_results.for_event_by_pool_type( event_by_pool_type ).is_not_disqualified.count > 0
            expect( active_swimmer.meeting_individual_results.for_event_by_pool_type( event_by_pool_type ).is_personal_best.count ).to be > 0
            event_swam += 1
          else
            expect( active_swimmer.meeting_individual_results.for_event_by_pool_type( event_by_pool_type ).is_personal_best.count ).to eq( 0 )
          end
          expect( active_swimmer.meeting_individual_results.is_personal_best.count ).to be >= event_swam
        end
      end
    end
    #-- -----------------------------------------------------------------------
  end
  #-- -------------------------------------------------------------------------
  #++

  context "without requested parameters" do
    it "raises an exception for wrong swimmer parameter" do
      expect{ SwimmerBestFinder.new }.to raise_error( ArgumentError )
      expect{ SwimmerBestFinder.new( 'Wrong type parameter' ) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
