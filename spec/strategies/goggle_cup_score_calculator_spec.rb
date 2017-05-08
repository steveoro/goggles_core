require 'rails_helper'


describe GoggleCupScoreCalculator, type: :strategy do
  let( :fix_goggle_cup )    { create(:goggle_cup) }
  let( :fix_swimmer )       { create(:swimmer) }
  let( :fix_pool_type )     { PoolType.only_for_meetings.sample }
  let( :fix_event_type )    { EventType.are_not_relays.order('RAND()').first }

  subject do
    GoggleCupScoreCalculator.new( fix_goggle_cup, fix_swimmer, fix_pool_type, fix_event_type )
  end


  context "with wrong parameters" do
    it "raises an error (with wrong goggle_cup)" do
      expect{ GoggleCupScoreCalculator.new( 'wrong_goggle_cup', fix_swimmer, fix_pool_type, fix_event_type) }.to raise_error( ArgumentError )
    end
    it "raises an error (with wrong swimmer)" do
      expect{ GoggleCupScoreCalculator.new( fix_goggle_cup, 'wrong_swimmer', fix_pool_type, fix_event_type) }.to raise_error( ArgumentError )
    end
    it "raises an error (with wrong pool_type)" do
      expect{ GoggleCupScoreCalculator.new( fix_goggle_cup, fix_swimmer, 'Wrong pool type', fix_event_type) }.to raise_error( ArgumentError )
    end
    it "raises an error (with wrong event_type)" do
      expect{ GoggleCupScoreCalculator.new( fix_goggle_cup, fix_swimmer, fix_pool_type, 'Wrong event type') }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  context "with requested parameters" do
    describe "#get_goggle_cup_standard," do
      it "responds to get_goggle_cup_standard methods" do
        expect(subject).to respond_to(:get_goggle_cup_standard)
      end
      it "returns a time standard instance if the request goggle cup standard exists" do
        create(:goggle_cup_standard,
          goggle_cup_id: fix_goggle_cup.id,
          swimmer_id:    fix_swimmer.id,
          event_type_id: fix_event_type.id,
          pool_type_id:  fix_pool_type.id
        ) if subject.get_goggle_cup_standard.nil?
        expect( subject.get_goggle_cup_standard ).to be_an_instance_of( GoggleCupStandard )
      end
      it "returns nil if the request goggle cup standard doesnt exists" do
        wrong_pool_type = PoolType.where( is_suitable_for_meetings: false ).first
        score_1000 = GoggleCupScoreCalculator.new( fix_goggle_cup, fix_swimmer, wrong_pool_type, fix_event_type )
        expect( score_1000.get_goggle_cup_standard ).to be_nil
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#get_goggle_cup_score," do
      let( :fix_time_swam )  { Timing.new(((rand * 99) % 99).to_i + 1, ((rand * 59) % 59).to_i + 1, ((rand * 10) % 10).to_i) }
      before(:each) do
        create(:goggle_cup_standard,
          goggle_cup_id: fix_goggle_cup.id,
          swimmer_id:    fix_swimmer.id,
          event_type_id: fix_event_type.id,
          pool_type_id:  fix_pool_type.id
        ) if subject.get_goggle_cup_standard.nil?
      end
      it "responds to #get_goggle_cup_score" do
        expect(subject).to respond_to(:get_goggle_cup_score)
      end
      it "returns a non-negative numeric value for a positive timing" do
        expect( subject.get_goggle_cup_score( fix_time_swam ) ).to be >= 0
      end
      #-- -----------------------------------------------------------------------
      #++

      context "goggle cup standard present" do
        it "checks for correct calculation for goggle cup standard present better than time swam" do
          worst_time_swam = Timing.new( subject.get_goggle_cup_standard.get_timing_instance.to_hundreds + 150 )
          expect( subject.get_goggle_cup_score(worst_time_swam) ).to be < fix_goggle_cup.max_points
        end
        it "checks for correct calculation for goggle cup standard present worst than time swam" do
          better_time_swam = Timing.new( subject.get_goggle_cup_standard.get_timing_instance.to_hundreds - 150 )
          expect( subject.get_goggle_cup_score(better_time_swam) ).to be > fix_goggle_cup.max_points
        end
        it "checks for correct calculation for goggle cup standard present equal to time swam" do
          same_time_swam = Timing.new( subject.get_goggle_cup_standard.get_timing_instance.to_hundreds )
          expect( subject.get_goggle_cup_score(same_time_swam) ).to eq( fix_goggle_cup.max_points )
        end
      end
      #-- -----------------------------------------------------------------------
      #++

      context "goggle cup standard not present" do
        it "checks for correct calculation for no goggle cup standard present" do
          wrong_pool_type = PoolType.where( is_suitable_for_meetings: false ).first
          score_1000 = GoggleCupScoreCalculator.new( fix_goggle_cup, fix_swimmer, wrong_pool_type, fix_event_type )
          expect( score_1000.get_goggle_cup_score( fix_time_swam ) ).to eq(fix_goggle_cup.max_points)
        end
        it "creates a new goggle cup standard" do
          wrong_pool_type = PoolType.where( is_suitable_for_meetings: false ).first
          score_1000 = GoggleCupScoreCalculator.new( fix_goggle_cup, fix_swimmer, wrong_pool_type, fix_event_type )
          expect( score_1000.get_goggle_cup_standard ).to be_nil
          score_1000.get_goggle_cup_score( fix_time_swam )
          expect( score_1000.get_goggle_cup_standard ).to be_an_instance_of( GoggleCupStandard )
        end
      end
      #-- -----------------------------------------------------------------------
      #++
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#set_goggle_cup_standard," do
      let( :fix_time_swam )  { Timing.new(((rand * 99) % 99).to_i + 1, ((rand * 59) % 59).to_i + 1, ((rand * 10) % 10).to_i) }

      it "responds to #set_goggle_cup_standard" do
        expect(subject).to respond_to(:set_goggle_cup_standard)
      end
      it "returns true" do
        expect( subject.set_goggle_cup_standard( fix_time_swam ) ).to be true
      end

      context "goggle cup standard doesn't exist" do
        let( :fix_new_standard ) do
          wrong_pool_type = PoolType.where( is_suitable_for_meetings: false ).first
          GoggleCupScoreCalculator.new( fix_goggle_cup, fix_swimmer, wrong_pool_type, fix_event_type )
        end

        it "goggle cup standard doesn't exists" do
          expect( fix_new_standard.get_goggle_cup_standard ).to be_nil
        end
        it "creates a new goggle cup standard" do
          expect( fix_new_standard.set_goggle_cup_standard( fix_time_swam ) ).to be true
        end
        it "goggle cup standard created is a GoggleCupStandard instance" do
          fix_new_standard.set_goggle_cup_standard( fix_time_swam )
          expect( fix_new_standard.get_goggle_cup_standard ).to be_an_instance_of( GoggleCupStandard )
        end
        it "goggle cup standard is equal to time swam" do
          fix_new_standard.set_goggle_cup_standard( fix_time_swam )
          expect( fix_new_standard.get_goggle_cup_standard.get_timing_instance.to_hundreds ).to eq( fix_time_swam.to_hundreds )
        end
        it "sets true are_goggle_cup_standards_updated?" do
          fix_new_standard.set_goggle_cup_standard( fix_time_swam )
          expect( fix_new_standard.are_goggle_cup_standards_updated? ).to be( true )
        end
        it "creates sql diff for insertion" do
          subject.set_goggle_cup_standard( fix_time_swam )
          expect( subject.sql_diff_text_log ).to include( 'Creating time standard for' )
        end
      end

      context "goggle cup standard already exists" do
        before :each do
          create(:goggle_cup_standard,
            goggle_cup_id: fix_goggle_cup.id,
            swimmer_id:    fix_swimmer.id,
            event_type_id: fix_event_type.id,
            pool_type_id:  fix_pool_type.id
          ) if subject.get_goggle_cup_standard.nil?
        end

        it "goggle cup standard exists" do
          expect( subject.get_goggle_cup_standard ).to be_an_instance_of( GoggleCupStandard )
        end
        it "updates the goggle cup standard" do
          expect( subject.set_goggle_cup_standard( fix_time_swam ) ).to be true
        end
        it "goggle cup standard is equal to time swam" do
          subject.set_goggle_cup_standard( fix_time_swam )
          expect( subject.get_goggle_cup_standard.get_timing_instance.to_hundreds ).to eq( fix_time_swam.to_hundreds )
        end
        it "sets true are_goggle_cup_standards_updated?" do
          subject.set_goggle_cup_standard( fix_time_swam )
          expect( subject.are_goggle_cup_standards_updated? ).to be( true )
        end
        it "creates sql diff for update" do
          subject.set_goggle_cup_standard( fix_time_swam )
          expect( subject.sql_diff_text_log ).to include( 'Updating time standard for' )
        end
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#are_goggle_cup_standards_updated?," do
      it "responds to are_goggle_cup_standards_updated? method" do
        expect(subject).to respond_to(:are_goggle_cup_standards_updated?)
      end
      it "returns false if no calculation done" do
        expect( subject.are_goggle_cup_standards_updated? ).to be( false )
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe "#get_swimmer_modifier," do
      it "responds to get_swimmer_modifier method" do
        expect(subject).to respond_to(:get_swimmer_modifier)
      end
      it "returns a number" do
        expect( subject.get_swimmer_modifier ).to be_a_kind_of( Float )
      end
      it "returns 0.0 if swimmer age between 20 and 60" do
        age = (21 + ((rand * 39) % 39).to_i) 
        expect( age ).to be > 20
        expect( age ).to be < 60
        normal_swimmer = create(:swimmer, year_of_birth: ( fix_goggle_cup.end_date.year - age ) )
        expect( normal_swimmer.get_swimmer_age(fix_goggle_cup.end_date) ).to be > 20
        expect( normal_swimmer.get_swimmer_age(fix_goggle_cup.end_date) ).to be < 60
        fix_gc = GoggleCupScoreCalculator.new( fix_goggle_cup, normal_swimmer, fix_pool_type, fix_event_type )
        expect( fix_gc.get_swimmer_modifier ).to be_equal( 0.0 )
      end
      it "returns 5.0 if swimmer age more than 60" do
        age = (61 + ((rand * 30) % 30).to_i) 
        expect( age ).to be > 60
        old_swimmer = create(:swimmer, year_of_birth: ( fix_goggle_cup.end_date.year - age ) )
        expect( old_swimmer.get_swimmer_age(fix_goggle_cup.end_date) ).to be > 60
        fix_gc = GoggleCupScoreCalculator.new( fix_goggle_cup, old_swimmer, fix_pool_type, fix_event_type )
        expect( fix_gc.get_swimmer_modifier ).to be_equal( 5.0 )
      end
      it "returns -10.0 if swimmer age less than 20" do
        age = (10 + ((rand * 10) % 10).to_i) 
        expect( age ).to be < 20
        young_swimmer = create(:swimmer, year_of_birth: ( fix_goggle_cup.end_date.year - age ) )
        expect( young_swimmer.get_swimmer_age(fix_goggle_cup.end_date) ).to be < 20
        fix_gc = GoggleCupScoreCalculator.new( fix_goggle_cup, young_swimmer, fix_pool_type, fix_event_type )
        expect( fix_gc.get_swimmer_modifier ).to be_equal( -10.0 )
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
