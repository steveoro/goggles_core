# encoding: utf-8

require 'rails_helper'


describe EnhanceIndividualRankingDAO::EIREventScoreDAO, type: :model do
  let(:season)  { Season.find(151) }
  let(:meeting) { season.meetings.has_results[ (rand * (season.meetings.has_results.count - 1)).to_i ] }
  let(:swimmer) { meeting.swimmers[ (rand * (meeting.swimmers.count - 1)).to_i ] }
  let(:mirs)    { meeting.meeting_individual_results.is_valid.where(["meeting_individual_results.swimmer_id = ?", swimmer.id]) }

  #let(:mir) { season.meeting_individual_results.is_valid[ ((rand * season.meeting_individual_results.is_valid.count) % season.meeting_individual_results.is_valid.count).to_i ] }
  #let(:mir) { meeting.meeting_individual_results.is_valid[ (rand * (meeting.meeting_individual_results.is_valid.count - 1)).to_i ] }
  let(:mir)     { create( :meeting_individual_result ) }

  subject { EnhanceIndividualRankingDAO::EIREventScoreDAO.new( mir ) }

  it_behaves_like( "(the existance of a method)", [
    :event_date, :event_type, :rank,
    :event_points, :enhance_points, :performance_points,
    :season, :pool_type, :event_type, :gender_type, :category_type, :swimmer,
    :get_total_points,
  ] )


  describe "#event_date" do
    it "is the event date for the meeting individual result used in construction" do
      expect( subject.event_date ).to eq( mir.meeting_session.scheduled_date )
    end
  end

  describe "#event_type" do
    it "is the event type for the meeting individual result used in construction" do
      expect( subject.event_type ).to eq( mir.event_type )
    end
  end

  describe "#rank" do
    it "is the rank for the meeting individual result used in construction" do
      expect( subject.rank ).to eq( mir.rank )
    end
  end

  describe "#event_points" do
    it "is the event points for the meeting individual result used in construction" do
      expect( subject.event_points ).to eq( mir.meeting_individual_points )
    end
  end

  describe "#enhance_points" do
    it "is a value between 0 and 10" do
      expect( subject.enhance_points ).to be >= 0
      expect( subject.enhance_points ).to be <= 10
    end
  end

  describe "#performance_points" do
    it "is a value between 0 and 150" do
      expect( subject.performance_points ).to be >= 0
      expect( subject.performance_points ).to be <= 150
    end
  end


  # Uses the score calculator class assumed correctly spec'd
  describe "#compute_performance_points" do
    it "returns a number >= 0" do
      expect( subject.compute_performance_points( 100, 0 ) ).to be >= 0
    end
    it "returns a number proportinale to the limit" do
      val_100 = subject.compute_performance_points( 100, 0 )
      val_500 = subject.compute_performance_points( 500, 0 )
      val_1000 = subject.compute_performance_points( 1000, 0 )
      expect( val_100 ).to be < val_500
      expect( val_500 ).to be < val_1000
      expect( ( val_100 * 10 ) + 10 ).to be >= val_1000
    end
  end


  describe "#compute_enhance_points" do
    it "returns a number between 0 and 10 with existing result" do
      existing_mir = meeting.meeting_individual_results.is_valid[ (rand * (meeting.meeting_individual_results.is_valid.count - 1)).to_i ]
      existing_eir = EnhanceIndividualRankingDAO::EIREventScoreDAO.new( existing_mir )
      expect( existing_eir.compute_enhance_points ).to be >= 0
      expect( existing_eir.compute_enhance_points ).to be <= 10
    end

    it "returns 0 if no time standard" do
      expect( SeasonPersonalStandard.has_standard?( mir.season.id, mir.swimmer_id, mir.pool_type.id, mir.event_type.id ) ).to be false
      expect( subject.compute_enhance_points ).to eq( 0 )
    end

# FIXME random failure
    xit "returns 0 if time swam worst than standard" do
      better_personal_standard = create( :season_personal_standard, season: mir.season, swimmer: mir.swimmer, event_type: mir.event_type, pool_type: mir.pool_type )
      expect( SeasonPersonalStandard.has_standard?( mir.season.id, mir.swimmer_id, mir.pool_type.id, mir.event_type.id ) ).to be true
      better_personal_standard.minutes = mir.minutes > 1 ? mir.minutes - 1 : 0
      better_personal_standard.seconds = mir.seconds > 14 ? mir.seconds - 14 : mir.seconds
      better_personal_standard.hundreds = 0
      better_personal_standard.save
      expect( SeasonPersonalStandard.get_standard( mir.season.id, mir.swimmer_id, mir.pool_type.id, mir.event_type.id ).get_timing_instance.to_hundreds ).to be < mir.get_timing_instance.to_hundreds
      expect( subject.compute_enhance_points ).to eq( 0 )
    end

    it "returns a value > 0 if time swam better than standard" do
      worst_personal_standard = create( :season_personal_standard, season: mir.season, swimmer: mir.swimmer, event_type: mir.event_type, pool_type: mir.pool_type )
      expect( SeasonPersonalStandard.has_standard?( mir.season.id, mir.swimmer_id, mir.pool_type.id, mir.event_type.id ) ).to be true
      worst_personal_standard.minutes = mir.minutes + 1
      worst_personal_standard.save
      expect( SeasonPersonalStandard.get_standard( mir.season.id, mir.swimmer_id, mir.pool_type.id, mir.event_type.id ).get_timing_instance.to_hundreds ).to be > mir.get_timing_instance.to_hundreds
      expect( subject.compute_enhance_points ).to be > 0
      expect( subject.compute_enhance_points ).to be <= 10
    end

    it "returns 10 if time swam better than 10% of standard" do
      time_standard = Timing.new( ( mir.get_timing_instance.to_hundreds * 1.2 ).to_i )
      worst_personal_standard = create( :season_personal_standard, season: mir.season, swimmer: mir.swimmer, event_type: mir.event_type, pool_type: mir.pool_type )
      expect( SeasonPersonalStandard.has_standard?( mir.season.id, mir.swimmer_id, mir.pool_type.id, mir.event_type.id ) ).to be true
      worst_personal_standard.minutes = time_standard.minutes
      worst_personal_standard.seconds = time_standard.seconds
      worst_personal_standard.hundreds = time_standard.hundreds
      worst_personal_standard.save
      expect( SeasonPersonalStandard.get_standard( mir.season.id, mir.swimmer_id, mir.pool_type.id, mir.event_type.id ).get_timing_instance.to_hundreds ).to eq( worst_personal_standard.get_timing_instance.to_hundreds )
      expect( subject.compute_enhance_points ).to eq( 10 )
    end

    it "returns a number corresponding to the improvement percentage" do
      improvement = 1 + ( ( rand * 10 ).to_i ) / 10
      time_standard = Timing.new( ( mir.get_timing_instance.to_hundreds * improvement ).to_i )
      worst_personal_standard = create( :season_personal_standard, season: mir.season, swimmer: mir.swimmer, event_type: mir.event_type, pool_type: mir.pool_type )
      expect( SeasonPersonalStandard.has_standard?( mir.season.id, mir.swimmer_id, mir.pool_type.id, mir.event_type.id ) ).to be true
      worst_personal_standard.minutes = time_standard.minutes
      worst_personal_standard.seconds = time_standard.seconds
      worst_personal_standard.hundreds = time_standard.hundreds
      worst_personal_standard.save
      expect( SeasonPersonalStandard.get_standard( mir.season.id, mir.swimmer_id, mir.pool_type.id, mir.event_type.id ).get_timing_instance.to_hundreds ).to eq( worst_personal_standard.get_timing_instance.to_hundreds )
      expect( subject.compute_enhance_points ).to eq( ( improvement - 1 ) * 10 )
    end
  end


  describe "#get_total_points" do
    it "is the sum of event_points, performance points and enhance_points" do
      expect( subject.get_total_points ).to eq( subject.enhance_points + subject.performance_points + subject.event_points )
    end
  end
end
#-- ---------------------------------------------------------------------------
#++
