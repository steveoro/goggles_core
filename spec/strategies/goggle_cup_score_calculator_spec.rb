require 'spec_helper'


describe GoggleCupScoreCalculator, type: :strategy do
  before :each do
    @fix_goggle_cup = create(:goggle_cup)
    @fix_swimmer    = create(:swimmer)

    # Data forced from seeds
    @fix_pool_type  = PoolType.only_for_meetings.sample
    @fix_event_type = EventType.are_not_relays.order('RAND()').first
  end

  context "with requested parameters" do
    subject { GoggleCupScoreCalculator.new( @fix_goggle_cup, @fix_swimmer, @fix_pool_type, @fix_event_type ) }

    describe "#get_goggle_cup_standard," do
      it "responds to get_goggle_cup_standard methods" do
        expect(subject).to respond_to(:get_goggle_cup_standard)
      end
      it "returns a time standard instance if the request goggle cup standard exists" do
        create(:goggle_cup_standard,
          goggle_cup_id: @fix_goggle_cup.id,
          swimmer_id: @fix_swimmer.id,
          event_type_id: @fix_event_type.id,
          pool_type_id: @fix_pool_type.id
        ) if subject.get_goggle_cup_standard.nil?
        expect( subject.get_goggle_cup_standard ).to be_an_instance_of( GoggleCupStandard )
      end
      it "returns nil if the request goggle cup standard doesnt exists" do
        wrong_pool_type = PoolType.where(is_suitable_for_meetings: false).first
        score_1000 = GoggleCupScoreCalculator.new( @fix_goggle_cup, @fix_swimmer, wrong_pool_type, @fix_event_type )
        expect( score_1000.get_goggle_cup_standard ).to be_nil
      end
    end
    #-- -----------------------------------------------------------------------

    describe "#get_goggle_cup_score," do
      before :each do
        @fix_time_swam = Timing.new(((rand * 99) % 99).to_i + 1, ((rand * 59) % 59).to_i + 1, ((rand * 10) % 10).to_i)
        create(:goggle_cup_standard,
          goggle_cup_id: @fix_goggle_cup.id,
          swimmer_id: @fix_swimmer.id,
          event_type_id: @fix_event_type.id,
          pool_type_id: @fix_pool_type.id
        ) if subject.get_goggle_cup_standard.nil?
      end
      it "responds to get_goggle_cup_score methods" do
        expect(subject).to respond_to(:get_goggle_cup_score)
      end
      it "returns a numeric value" do
        expect( subject.get_goggle_cup_score(@fix_time_swam) ).to be >= 0
      end
      #-- -----------------------------------------------------------------------

      context "goggle cup standard present" do
        it "checks for correct calculation for goggle cup standard present better than time swam" do
          worst_time_swam = Timing.new(subject.get_goggle_cup_standard.get_timing_instance.to_hundreds + 150)
          expect( subject.get_goggle_cup_score(worst_time_swam) ).to be < @fix_goggle_cup.max_points
        end
        it "checks for correct calculation for goggle cup standard present worst than time swam" do
          better_time_swam = Timing.new(subject.get_goggle_cup_standard.get_timing_instance.to_hundreds - 150)
          expect( subject.get_goggle_cup_score(better_time_swam) ).to be > @fix_goggle_cup.max_points
        end
        it "checks for correct calculation for goggle cup standard present equal to time swam" do
          same_time_swam = Timing.new(subject.get_goggle_cup_standard.get_timing_instance.to_hundreds)
          expect( subject.get_goggle_cup_score(same_time_swam) ).to eq(@fix_goggle_cup.max_points)
        end
      end
      #-- -----------------------------------------------------------------------

      context "goggle cup standard not present" do
        it "checks for correct calculation for no goggle cup standard present" do
          wrong_pool_type = PoolType.where(is_suitable_for_meetings: false).first
          score_1000 = GoggleCupScoreCalculator.new( @fix_goggle_cup, @fix_swimmer, wrong_pool_type, @fix_event_type )
          expect( score_1000.get_goggle_cup_score(@fix_time_swam) ).to eq(@fix_goggle_cup.max_points)
        end
        it "creates a new goggle cup standard" do
          wrong_pool_type = PoolType.where(is_suitable_for_meetings: false).first
          score_1000 = GoggleCupScoreCalculator.new( @fix_goggle_cup, @fix_swimmer, wrong_pool_type, @fix_event_type )
          expect( score_1000.get_goggle_cup_standard ).to be_nil
          score_1000.get_goggle_cup_score(@fix_time_swam)
          expect( score_1000.get_goggle_cup_standard ).to be_an_instance_of( GoggleCupStandard )
        end
      end
      #-- -----------------------------------------------------------------------
    end
    #-- -----------------------------------------------------------------------

    describe "#set_goggle_cup_standard," do
      before :each do
        @fix_time_swam = Timing.new(((rand * 99) % 99).to_i + 1, ((rand * 59) % 59).to_i + 1, ((rand * 10) % 10).to_i)
      end
      it "responds to set_goggle_cup_standard methods" do
        expect(subject).to respond_to(:set_goggle_cup_standard)
      end
      it "returns true" do
        expect( subject.set_goggle_cup_standard(@fix_time_swam) ).to be true
      end

      context "goggle cup standard doesn't exist" do
        before :each do
          wrong_pool_type = PoolType.where(is_suitable_for_meetings: false).first
          @fix_new_standard = GoggleCupScoreCalculator.new( @fix_goggle_cup, @fix_swimmer, wrong_pool_type, @fix_event_type )
        end

        it "goggle cup standard doesn't exists" do
          expect( @fix_new_standard.get_goggle_cup_standard ).to be_nil
        end
        it "creates a new goggle cup standard" do
          expect( @fix_new_standard.set_goggle_cup_standard(@fix_time_swam) ).to be true
        end
        it "goggle cup standard created is a GoggleCupStandard instance" do
          @fix_new_standard.set_goggle_cup_standard(@fix_time_swam)
          expect( @fix_new_standard.get_goggle_cup_standard ).to be_an_instance_of( GoggleCupStandard )
        end
        it "goggle cup standard is equal to time swam" do
          @fix_new_standard.set_goggle_cup_standard(@fix_time_swam)
          expect( @fix_new_standard.get_goggle_cup_standard.get_timing_instance.to_hundreds ).to be @fix_time_swam.to_hundreds
        end
      end

      context "goggle cup standard already exists" do
        before :each do
          @fix_time_swam = Timing.new(((rand * 99) % 99).to_i + 1, ((rand * 59) % 59).to_i + 1, ((rand * 10) % 10).to_i)
          create(:goggle_cup_standard,
            goggle_cup_id: @fix_goggle_cup.id,
            swimmer_id: @fix_swimmer.id,
            event_type_id: @fix_event_type.id,
            pool_type_id: @fix_pool_type.id
          ) if subject.get_goggle_cup_standard.nil?
        end

        it "goggle cup standard exists" do
          expect( subject.get_goggle_cup_standard ).to be_an_instance_of( GoggleCupStandard )
        end
        it "updates the goggle cup standard" do
          expect( subject.set_goggle_cup_standard(@fix_time_swam) ).to be true
        end
        it "goggle cup standard is equal to time swam" do
          subject.set_goggle_cup_standard(@fix_time_swam)
          expect( subject.get_goggle_cup_standard.get_timing_instance.to_hundreds ).to be @fix_time_swam.to_hundreds
        end
      end
    end
    #-- -----------------------------------------------------------------------
  end
  #-- -----------------------------------------------------------------------

  context "without requested parameters" do
    xit "raises an exception with wrong goggle_cup" do
      expect( GoggleCupScoreCalculator.new( 'wrong_goggle_cup', @fix_swimmer, @fix_pool_type, @fix_event_type) ).to raise_error( ArgumentError )
    end
    xit "raises an exception with wrong swimmer" do
      expect( GoggleCupScoreCalculator.new( @fix_goggle_cup, 'wrong_swimmer', @fix_pool_type, @fix_event_type) ).to raise_error( ArgumentError )
    end
    xit "raises an exception with wrong goggle_cup" do
      expect( GoggleCupScoreCalculator.new( @fix_goggle_cup, @fix_swimmer, 'Wrong pool type', @fix_event_type) ).to raise_error( ArgumentError )
    end
    xit "raises an exception with wrong goggle_cup" do
      expect( GoggleCupScoreCalculator.new( @fix_goggle_cup, @fix_swimmer, @fix_pool_type, 'Wrong event type') ).to raise_error( ArgumentError )
    end
  end
  #-- -----------------------------------------------------------------------
end
