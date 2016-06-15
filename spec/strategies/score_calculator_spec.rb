require 'spec_helper'


describe ScoreCalculator, type: :strategy do
  let( :standard_points ) { ( ( rand * 999 ).to_i + 1 ) }
  let( :fix_time_swam )   { Timing.new(((rand * 99) % 99).to_i + 1, ((rand * 59) % 59).to_i + 1, ((rand * 10) % 10).to_i) }

  before :each do
    @fix_season        = Season.find(142)
    # Get a random meeting chosen among the first 10:
    fixture_meeting    = @fix_season.meetings.has_results.all.to_ary[0..9].sort{ rand - 0.5 }[0]
    # Get a random swimmer result among the ones available:
    fixture_mir        = fixture_meeting.meeting_individual_results.all.sort{ rand - 0.5 }[0]
    @fix_gender_type   = fixture_mir.gender_type
    @fix_category_type = fixture_mir.category_type
    @fix_pool_type     = fixture_mir.pool_type
    @fix_event_type    = fixture_mir.event_type
    # Old method by Leega:
#    @fix_swimmer = create(:swimmer)
#    @fix_gender_type   = @fix_swimmer.gender_type
#    @fix_category_type = @fix_swimmer.get_category_type_for_season( @fix_season.id )
#    @fix_pool_type     = PoolType.only_for_meetings.find( ((rand * 2) % 2).to_i + 1 )
#    @fix_event_type    = EventType.are_not_relays.find( ((rand * 20) % 20).to_i + 1 )
  end

  context "with requested parameters for given swimmer" do
    subject { ScoreCalculator.new( @fix_season, @fix_gender_type, @fix_category_type, @fix_pool_type, @fix_event_type ) }

    describe "#get_time_standard," do
      it "responds to get_time_standard methods" do
        expect(subject).to respond_to(:get_time_standard)
      end
      it "returns a time standard istance if the request time standard exists" do
        create(:time_standard,
          season_id: @fix_season.id,
          gender_type_id: @fix_gender_type.id,
          category_type_id: @fix_category_type.id,
          event_type_id: @fix_event_type.id,
          pool_type_id: @fix_pool_type.id
        ) if subject.get_time_standard.nil?
        expect( subject.get_time_standard ).to be_an_instance_of( TimeStandard )
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_fin_score," do
      before :each do
        @fix_time_swam = Timing.new(((rand * 99) % 99).to_i + 1, ((rand * 59) % 59).to_i + 1, ((rand * 10) % 10).to_i)
        create(:time_standard,
          season_id: @fix_season.id,
          gender_type_id: @fix_gender_type.id,
          category_type_id: @fix_category_type.id,
          event_type_id: @fix_event_type.id,
          pool_type_id: @fix_pool_type.id
        ) if subject.get_time_standard.nil?
      end
      it "responds to get_fin_score methods" do
        expect(subject).to respond_to(:get_fin_score)
      end
      it "returns a numeric value" do
        expect( subject.get_fin_score(@fix_time_swam) ).to be >= 0
      end
      #-- -----------------------------------------------------------------------

      it "checks for correct calculation for no time standard present" do
        wrong_pool_type = PoolType.where(is_suitable_for_meetings: false).first
        score_1000 = ScoreCalculator.new( @fix_season, @fix_gender_type, @fix_category_type, wrong_pool_type, @fix_event_type )
        expect( score_1000.get_fin_score(@fix_time_swam) ).to eq(1000)
      end
      it "checks for correct calculation for time standard present better than time swam" do
        worst_time_swam = Timing.new(subject.get_time_standard.get_timing_instance.to_hundreds + 150)
        expect( subject.get_fin_score(worst_time_swam) ).to be < 1000
      end
      it "checks for correct calculation for time standard present worst than time swam" do
        better_time_swam = Timing.new(subject.get_time_standard.get_timing_instance.to_hundreds - 150)
        expect( subject.get_fin_score(better_time_swam) ).to be > 1000
      end
      it "checks for correct calculation for time standard present equal to time swam" do
        same_time_swam = Timing.new(subject.get_time_standard.get_timing_instance.to_hundreds)
        expect( subject.get_fin_score(same_time_swam) ).to eq(1000)
      end
      #-- -----------------------------------------------------------------------
    end
    #-- -----------------------------------------------------------------------

    describe "#get_custom_score," do
      before :each do
        create(:time_standard,
          season_id: @fix_season.id,
          gender_type_id: @fix_gender_type.id,
          category_type_id: @fix_category_type.id,
          event_type_id: @fix_event_type.id,
          pool_type_id: @fix_pool_type.id
        ) if subject.get_time_standard.nil?
      end
      
      it "responds to get_custom_score methods" do
        expect(subject).to respond_to(:get_custom_score)
      end
      it "returns a numeric value" do
        expect( subject.get_custom_score( fix_time_swam, standard_points ) ).to be >= 0
      end
      #-- -----------------------------------------------------------------------

      it "checks for correct calculation for no time standard present" do
        wrong_pool_type = PoolType.where(is_suitable_for_meetings: false).first
        score_1000 = ScoreCalculator.new( @fix_season, @fix_gender_type, @fix_category_type, wrong_pool_type, @fix_event_type )
        expect( score_1000.get_custom_score( fix_time_swam, standard_points ) ).to eq( standard_points )
      end
      it "checks for correct calculation for time standard present better than time swam" do
        worst_time_swam = Timing.new(subject.get_time_standard.get_timing_instance.to_hundreds + 150)
        expect( subject.get_custom_score( worst_time_swam, standard_points ) ).to be < standard_points
      end
      it "checks for correct calculation for time standard present worst than time swam" do
        better_time_swam = Timing.new(subject.get_time_standard.get_timing_instance.to_hundreds - 150)
        expect( subject.get_custom_score( better_time_swam, standard_points ) ).to be > standard_points
      end
      it "checks for correct calculation for time standard present equal to time swam" do
        same_time_swam = Timing.new(subject.get_time_standard.get_timing_instance.to_hundreds)
        expect( subject.get_custom_score( same_time_swam, standard_points ) ).to eq( standard_points )
      end
      #-- -----------------------------------------------------------------------
    end
    #-- -----------------------------------------------------------------------

    describe "#get_fin_timing," do
      before :each do
        @fix_goal_score = ((rand * 550) + 500).round(2)
        create(:time_standard,
          season_id: @fix_season.id,
          gender_type_id: @fix_gender_type.id,
          category_type_id: @fix_category_type.id,
          event_type_id: @fix_event_type.id,
          pool_type_id: @fix_pool_type.id
        ) if subject.get_time_standard.nil?
      end
      it "responds to get_fin_timing methods" do
        expect(subject).to respond_to(:get_fin_timing)
      end
      it "returns a timing value" do
        expect( subject.get_fin_timing( @fix_goal_score ) ).to be_an_instance_of( Timing )
      end
      #-- -----------------------------------------------------------------------

      it "checks for correct calculation for no time standard present" do
        wrong_pool_type = PoolType.where(is_suitable_for_meetings: false).first
        no_standard_time = ScoreCalculator.new( @fix_season, @fix_gender_type, @fix_category_type, wrong_pool_type, @fix_event_type )
        expect( no_standard_time.get_fin_timing( @fix_goal_score ).to_hundreds ).to eq( 0 )
      end
      it "checks for correct calculation for goal score > 1000" do
        score_over_1000 = ((rand * 100) + 1000.01).round(2)
        expect( subject.get_fin_timing( score_over_1000 ).to_hundreds ).to be <= subject.get_time_standard.get_timing_instance.to_hundreds
      end
      it "checks for correct calculation for goal score < 1000" do
        score_under_1000 = ((rand * 500) + 499.99).round(2)
        expect( subject.get_fin_timing( score_under_1000 ).to_hundreds ).to be >= subject.get_time_standard.get_timing_instance.to_hundreds
      end
      it "checks for correct calculation for goal score 1000" do
        score_1000 = 1000.round(2)
        expect( subject.get_fin_timing( score_1000 ).to_hundreds ).to eq( subject.get_time_standard.get_timing_instance.to_hundreds )
      end
      #-- -----------------------------------------------------------------------
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end
