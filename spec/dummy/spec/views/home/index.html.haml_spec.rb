require 'rails_helper'

RSpec.describe "home/index.html.haml", :type => :view do
  it "renders the admin-only page" do
    render
    # Check for the specific texts that signal the exact rendering of the page:
    expect( rendered ).to include( "Find me in app/views/home/index.html.haml" )
    # Default rendering assumes no user logged at all:
    expect( rendered ).to include( "/users/sign_in" )
    expect( rendered ).to include( "/users/sign_up" )
    expect( rendered ).not_to include( "/users/sign_out" )
  end
end
