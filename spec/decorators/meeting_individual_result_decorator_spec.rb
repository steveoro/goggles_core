require 'spec_helper'


describe MeetingIndividualResultDecorator, type: :model do
  include Rails.application.routes.url_helpers

  before :each do
    @mir = build( :meeting_individual_result )
    expect( @mir ).to be_an_instance_of(MeetingIndividualResult)
    @decorated_instance = MeetingIndividualResultDecorator.decorate( @mir )
  end

  subject { @decorated_instance }


  context "[implemented methods]" do
    it_behaves_like( "(the existance of a method)", [
        :get_rank_description, :show_any_rank_medal
      ]
    )
  end
  #-- --------------------------------------------------------------------------
  #++


  describe "#get_rank_description" do
    context "when called on a non-DSQ instance," do
      it "returns the rank value" do
        subject.is_disqualified = false
        subject.disqualification_code_type_id = nil
        expect( subject.get_rank_description ).to eq( subject.rank )
      end
    end

    context "when called on a DSQ instance," do
      it "returns the localized DSQ description" do
        subject.is_disqualified = true
        subject.disqualification_code_type_id = DisqualificationCodeType::DSQ_FALSE_START_ID
        expect( subject.get_rank_description ).to eq( I18n.t('disqualification_code_types.generic_dsq_code') )
      end
    end

    context "when called on a RET instance," do
      it "returns the localized RET description" do
        subject.is_disqualified = true
        subject.disqualification_code_type_id = DisqualificationCodeType::DSQ_RETIRED_ID
        expect( subject.get_rank_description ).to eq( I18n.t('disqualification_code_types.generic_ret_code') )
      end
    end
  end
  #-- --------------------------------------------------------------------------
  #++


  describe "#show_any_rank_medal" do
    context "when called on ranked #1 result," do
      it "returns the image tag for a gold medal" do
        subject.rank = 1
        subject.is_out_of_race = false
        subject.is_disqualified = false
        result = subject.show_any_rank_medal
        expect( result ).to include( "gold" )
      end
    end

    context "when called on ranked #2 result," do
      it "returns the image tag for a silver medal" do
        subject.rank = 2
        subject.is_out_of_race = false
        subject.is_disqualified = false
        result = subject.show_any_rank_medal
        expect( result ).to include( "silver" )
      end
    end

    context "when called on ranked #3 result," do
      it "returns the image tag for a bronze medal" do
        subject.rank = 3
        subject.is_out_of_race = false
        subject.is_disqualified = false
        result = subject.show_any_rank_medal
        expect( result ).to include( "bronze" )
      end
    end

    context "when called on a DSQ instance," do
      it "returns an empty string" do
        subject.rank = 3
        subject.is_disqualified = true
        result = subject.show_any_rank_medal
        expect( result ).to eq("")
      end
    end

    context "when called on a ranked > 3 result," do
      it "returns an empty string" do
        subject.rank = 4
        subject.is_out_of_race = false
        subject.is_disqualified = false
        result = subject.show_any_rank_medal
        expect( result ).to eq("")
      end
    end
  end
  #-- --------------------------------------------------------------------------
  #++


  describe "#get_formatted_standard_points" do
    context "when called on a result with 0 points," do
      it "returns an empty string" do
        subject.standard_points = 0
        expect( subject.get_formatted_standard_points ).to eq( "" )
      end
    end

    context "when called on a result with positive points," do
      it "returns the score formatted with decimals" do
        subject.standard_points = 10.5
        expect( subject.get_formatted_standard_points ).to eq( "10.50" )
      end
      it "returns the score formatted with decimals, even when integer" do
        subject.standard_points = 20
        expect( subject.get_formatted_standard_points ).to eq( "20.00" )
      end
    end

    context "when called on a result with 0 points but show_even_when_zero=true," do
      it "returns the (zero) score formatted with decimals" do
        subject.standard_points = 0
        expect( subject.get_formatted_standard_points(true) ).to eq( "0.00" )
      end
    end
  end


  describe "#get_formatted_individual_points" do
    context "when called on a result with 0 points," do
      it "returns an empty string" do
        subject.meeting_individual_points = 0
        expect( subject.get_formatted_individual_points ).to eq( "" )
      end
    end

    context "when called on a result with positive points," do
      it "returns the score formatted with decimals" do
        subject.meeting_individual_points = 30.75
        expect( subject.get_formatted_individual_points ).to eq( "30.75" )
      end
      it "returns the score formatted with decimals, even when integer" do
        subject.meeting_individual_points = 40
        expect( subject.get_formatted_individual_points ).to eq( "40.00" )
      end
    end

    context "when called on a result with 0 points but show_even_when_zero=true," do
      it "returns the (zero) score formatted with decimals" do
        subject.meeting_individual_points = 0
        expect( subject.get_formatted_individual_points(true) ).to eq( "0.00" )
      end
    end
  end

  describe "#get_formatted_goggle_cup_points" do
    context "when called on a result with 0 points," do
      it "returns an empty string" do
        subject.goggle_cup_points = 0
        expect( subject.get_formatted_goggle_cup_points ).to eq( "" )
      end
    end

    context "when called on a result with positive points," do
      it "returns the score formatted with decimals" do
        subject.goggle_cup_points = 980.75
        expect( subject.get_formatted_goggle_cup_points ).to eq( "980.75" )
      end
      it "returns the score formatted with decimals, even when integer" do
        subject.goggle_cup_points = 1000
        expect( subject.get_formatted_goggle_cup_points ).to eq( "1000.00" )
      end
    end

    context "when called on a result with 0 points but show_even_when_zero=true," do
      it "returns the (zero) score formatted with decimals" do
        subject.goggle_cup_points = 0
        expect( subject.get_formatted_goggle_cup_points(true) ).to eq( "0.00" )
      end
    end
  end
  #-- --------------------------------------------------------------------------
  #++
end
