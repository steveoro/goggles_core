# encoding: utf-8

require 'rails_helper'


describe EnhanceIndividualRankingDAO::EIRGenderCategoryRankingDAO, type: :model do
  let(:season)  { Season.find(151) }
  let(:meeting) { season.meetings.has_results[ (rand * (season.meetings.has_results.count - 1)).to_i ] }
  let(:swimmer) { meeting.swimmers[ (rand * (meeting.swimmers.count - 1)).to_i ] }
  let(:mirs)    { meeting.meeting_individual_results.is_valid.where(["meeting_individual_results.swimmer_id = ?", swimmer.id]) }


  subject { EnhanceIndividualRankingDAO::EIRGenderCategoryRankingDAO.new( season, swimmer.gender_type, swimmer.get_category_type_for_season( season.id ) ) }

  it_behaves_like( "(the existance of a method)", [
    :gender_type, :category_type, :swimmers,
  ] )

  describe "#category_type" do
    it "is the category_type of the swimmer in the season" do
      expect( subject.category_type ).to eq( swimmer.get_category_type_for_season( season.id ) )
    end
  end

  describe "#gender_type" do
    it "is the gender_type of the swimmer" do
      expect( subject.gender_type ).to eq( swimmer.gender_type )
    end
  end

  describe "#swimmers" do
    it "is a collection of BIRSwimmerScoreDAO" do
      expect( subject.swimmers ).to be_a_kind_of( Enumerable )
      expect( subject.swimmers ).to all(be_a_kind_of( EnhanceIndividualRankingDAO::EIRSwimmerScoreDAO ))
    end
    it "is has no more than one instance per each swimmer of the season" do
      expect( subject.swimmers.count ).to be <= season.swimmers.count
    end
  end
end
#-- ---------------------------------------------------------------------------
#++
