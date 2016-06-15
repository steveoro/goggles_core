require 'rails_helper'


RSpec.describe "Sessions", type: :routing do
  describe "routing" do
    routes { Engine.routes }

    # User Log-in / Log-out:
    it "routes to /users/sign_in" do
      expect( get( "/users/sign_in" ) ).to route_to( "devise/sessions#new" )
    end
    it "routes to POST /users/sign_in" do
      expect( post( "/users/sign_in" ) ).to route_to( "devise/sessions#create" )
    end
    it "routes to DEL /users/sign_out" do
      expect( delete( "/users/sign_out" ) ).to route_to( "devise/sessions#destroy" )
    end

    # User password change:
    it "routes to POST /users/password" do
      expect( post( "/users/password" ) ).to route_to( "devise/passwords#create" )
    end
    it "routes to /users/password/new" do
      expect( get( "/users/password/new" ) ).to route_to( "devise/passwords#new" )
    end
    it "routes to /users/password/edit" do
      expect( get( "/users/password/edit" ) ).to route_to( "devise/passwords#edit" )
    end
    it "routes to PUT /users/password" do
      expect( put( "/users/password" ) ).to route_to( "devise/passwords#update" )
    end

    # User registration:
    it "routes to /users/cancel" do
      expect( get( "/users/cancel" ) ).to route_to( "devise/registrations#cancel" )
    end
    it "routes to POST /users" do
      expect( post( "/users" ) ).to route_to( "devise/registrations#create" )
    end
    it "routes to /users/sign_up" do
      expect( get( "/users/sign_up" ) ).to route_to( "devise/registrations#new" )
    end
    it "routes to /users/edit" do
      expect( get( "/users/edit" ) ).to route_to( "devise/registrations#edit" )
    end
    it "routes to PUT /users" do
      expect( put( "/users" ) ).to route_to( "devise/registrations#update" )
    end
    it "routes to DEL /users" do
      expect( delete( "/users" ) ).to route_to( "devise/registrations#destroy" )
    end

    # User confirmation link:
    it "routes to POST /users/confirmation" do
      expect( post( "/users/confirmation" ) ).to route_to( "devise/confirmations#create" )
    end
    it "routes to /users/confirmation/new" do
      expect( get( "/users/confirmation/new" ) ).to route_to( "devise/confirmations#new" )
    end
    it "routes to /users/confirmation" do
      expect( get( "/users/confirmation" ) ).to route_to( "devise/confirmations#show" )
    end
  end
end
