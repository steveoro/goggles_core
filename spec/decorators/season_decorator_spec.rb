require 'spec_helper'


describe SeasonDecorator do
  include Rails.application.routes.url_helpers

  before :each do
    #season = Season.find_by_id( (rand * (Season.count - 1)).to_i + 1 )
    season = create(:season)
    expect( season ).to be_an_instance_of( Season )
    @decorated_instance = season.decorate
  end

  subject { @decorated_instance }

  describe "#get_linked_header_year" do
    it "responds to #get_linked_header_year method" do
      expect( subject ).to respond_to( :get_linked_header_year )
    end
    it "returns an HTML link" do
      expect( subject.get_linked_header_year ).to include( 'href' )
    end
    it "returns an HTML link to the season path" do
      expect( subject.get_linked_header_year ).to include( championships_ranking_regional_er_csi_path(id: subject.id) ).or include( championships_ranking_supermaster_fin_path(id: subject.id) ) 
    end
    it "returns a string containing the season header year" do
      expect( subject.get_linked_header_year ).to include( ERB::Util.html_escape(subject.header_year) )
    end
  end
  #-- --------------------------------------------------------------------------
  #++

  describe "#get_linked_full_name" do
    it "responds to #get_linked_full_name method" do
      expect( subject ).to respond_to( :get_linked_full_name )
    end
    it "returns an HTML link" do
      expect( subject.get_linked_full_name ).to include( 'href' )
    end
    it "returns an HTML link to the season path" do
      expect( subject.get_linked_full_name ).to include( championships_ranking_regional_er_csi_path(id: subject.id) ).or include( championships_ranking_supermaster_fin_path(id: subject.id) ) 
    end
    it "returns a string containing the season full name" do
      expect( subject.get_linked_full_name ).to include( ERB::Util.html_escape(subject.get_full_name) )
    end
  end
  #-- --------------------------------------------------------------------------
  #++
end
