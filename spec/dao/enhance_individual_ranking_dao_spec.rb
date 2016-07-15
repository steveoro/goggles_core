# encoding: utf-8

require 'rails_helper'


describe EnhanceIndividualRankingDAO, type: :model do
  let(:season)  { Season.find(151) }
  let(:meeting) { season.meetings.has_results[ (rand * (season.meetings.has_results.count - 1)).to_i ] }
  let(:swimmer) { meeting.swimmers[ (rand * (meeting.swimmers.count - 1)).to_i ] }
  let(:mirs)    { meeting.meeting_individual_results.is_valid.where(["meeting_individual_results.swimmer_id = ?", swimmer.id]) }


  context "as a valid instance," do

    subject { EnhanceIndividualRankingDAO.new( season ) }

    it_behaves_like( "(the existance of a method)", [
      :season, :gender_and_categories, :meetings_with_results,
      :get_ranking_for_gender_and_category, :scan_for_gender_and_category, :calculate_ranking, :set_ranking_for_gender_and_category
    ] )

    describe "#season" do
      it "is the season specified for the construction" do
        expect( subject.season ).to eq( season )
      end
    end
    describe "#gender_and_categories" do
      it "is a collection of BIRSwimmerScoreDAO" do
        subject.scan_for_gender_and_category
        expect( subject.gender_and_categories ).to be_a_kind_of( Enumerable )
        expect( subject.gender_and_categories ).to all(be_a_kind_of( EnhanceIndividualRankingDAO::EIRGenderCategoryRankingDAO ))
      end
    end
    describe "#meetings_with_results" do
      it "is a collection of Meeting" do
        expect( subject.meetings_with_results ).to be_a_kind_of( ActiveRecord::Relation )
        expect( subject.meetings_with_results ).to all(be_a_kind_of( Meeting ))
      end
      it "has a count between 0 and total season meetings" do
        expect( subject.meetings_with_results.count ).to be >= 0
        expect( subject.meetings_with_results.count ).to be <= season.meetings.count
      end
    end

    describe "#get_ranking_for_gender_and_category" do
      it "returns null if ranking not calculated" do
        expect( subject.get_ranking_for_gender_and_category( swimmer.gender_type, swimmer.get_category_type_for_season( season.id ) ) ).to be_nil
      end
      it "returns a BIRSwimmerScoreDAO if ranking calculated" do
        subject.set_ranking_for_gender_and_category( swimmer.gender_type, swimmer.get_category_type_for_season( season.id ) )
        expect( subject.get_ranking_for_gender_and_category( swimmer.gender_type, swimmer.get_category_type_for_season( season.id ) ) ).to be_a_kind_of( EnhanceIndividualRankingDAO::EIRGenderCategoryRankingDAO )
      end
    end

    describe "#set_ranking_for_gender_and_category" do
      it "increments the rank calculated" do
        subject.gender_and_categories.clear
        prev_rank = subject.gender_and_categories.size
        subject.set_ranking_for_gender_and_category( swimmer.gender_type, swimmer.get_category_type_for_season( season.id ) )
        expect( subject.gender_and_categories.size ).to be > prev_rank
      end
    end

    describe "#calculate_ranking" do
      it "returns a BIRSwimmerScoreDAO" do
        expect( subject.calculate_ranking( swimmer.gender_type, swimmer.get_category_type_for_season( season.id ) ) ).to be_a_kind_of( EnhanceIndividualRankingDAO::EIRGenderCategoryRankingDAO )
      end
    end

    describe "#scan_for_gender_and_category" do
      it "returns a collection of BIRSwimmerScoreDAO" do
        subject.gender_and_categories.clear
        subject.scan_for_gender_and_category
        expect( subject.gender_and_categories.size ).to be > 0
        expect( subject.gender_and_categories ).to all(be_a_kind_of( EnhanceIndividualRankingDAO::EIRGenderCategoryRankingDAO ))
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++


  context "as an invalid instance" do
    it "raises an exception for wrong season parameter" do
      expect{ EnhanceIndividualRankingDAO.new( 'Wrong parameter' ) }.to raise_error( ArgumentError )
      expect{ EnhanceIndividualRankingDAO.new( meeting ) }.to raise_error( ArgumentError )
    end
  end
  #-- -------------------------------------------------------------------------
  #++
end

