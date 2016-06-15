require 'rails_helper'


RSpec.describe HomeController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect( get("/index") ).to route_to( "home#index" )
    end

    it "routes to #restricted_info" do
      expect( get("/restricted_info") ).to route_to( "home#restricted_info" )
    end
  end
end
