# encoding: utf-8

require 'spec_helper'

describe ChampionshipDAO, type: :model do
  let(:team)          { create(:team) }
  let(:columns)       { [:season_individual_points, :season_relay_points] }
  let(:meetings)      { Season.find(131).meetings }

  context "TeamScoreDAO subclass," do
    subject { ChampionshipDAO::TeamScoreDAO.new( team ) }

    it_behaves_like( "(the existance of a method)", [
      :team, :meetings, :total_points, :add_meeting
    ] )

    describe "#team" do
      it "is the team specified for the construction" do
        expect( subject.team ).to eq( team )
      end
    end
    describe "#meetings" do
      it "is the defaut value for meetings" do
        expect( subject.meetings ).to eq( [] )
      end
    end
    describe "#total_points" do
      it "is the defaut value for total_points" do
        expect( subject.total_points ).to eq( 0 )
      end
    end
    
    describe "#add_meetings" do
      xit "adds an element to meetings (array) attribute"
      xit "computes the total_points"
    end
  end
  #-- -------------------------------------------------------------------------
  #++
  

  context "as a valid instance," do
    let(:team_scores)   { [ ChampionshipDAO::TeamScoreDAO.new( team ) ] }

    subject { ChampionshipDAO.new( columns, meetings, team_scores ) }

    it_behaves_like( "(the existance of a method)", [
      :columns, :meetings, :team_scores
    ] )

    describe "#columns" do
      it "is the array specified for the construction" do
        expect( subject.columns ).to eq( columns )
      end
    end
    describe "#meetings" do
      it "is the relation specified for the construction" do
        expect( subject.meetings ).to eq( meetings )
      end
    end
    describe "#team_scores" do
      it "is the array specified for the construction" do
        expect( subject.team_scores ).to eq( team_scores )
      end
    end
  end
  #-- -------------------------------------------------------------------------
  #++

  
  context "not a valid instance" do   
    it "raises an exception for wrong team parameter" do
      expect{ ChampionshipDAO.new( columns, meetings, 'Wrong parameter' ) }.to raise_error( ArgumentError )
    end   
    it "raises an exception for wrong team parameter element types" do
      expect{ ChampionshipDAO.new( columns, meetings, ['Wrong parameter'] ) }.to raise_error( ArgumentError )
    end   
  end
  #-- -------------------------------------------------------------------------
  #++
end

