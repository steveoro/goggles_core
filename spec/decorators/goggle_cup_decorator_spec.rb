require 'spec_helper'


describe GoggleCupDecorator, type: :model do
  include Rails.application.routes.url_helpers

  before :each do
    @goggle_cup = create( :goggle_cup )
    @decorated_goggle_cup = GoggleCupDecorator.decorate( @goggle_cup )
  end

  subject { @decorated_goggle_cup }

  describe "#get_linked_name" do
    it "responds to #get_linked_name method" do
      expect( subject ).to respond_to( :get_linked_name )
    end
    it "returns an HTML link" do
      expect( subject.get_linked_name ).to include( 'href' )
    end
    it "returns an HTML link to the team goggle cup path" do
      expect( subject.get_linked_name ).to include( team_closed_goggle_cup_path(id: subject.id) )
    end
    it "returns a string containing the goggle cup full name" do
      expect( subject.get_linked_name ).to include( ERB::Util.html_escape(subject.get_full_name) )
    end
  end
  #-- --------------------------------------------------------------------------
  #++
end
