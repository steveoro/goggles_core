require 'rails_helper'

RSpec.describe "home/restricted_info.html.haml", :type => :view do
  before(:each)  do
    assign( :for_user_eyes_only, "This should be viewed only by a logged-id User!" )
    # Stub-out the required and authorized user before rendering the view:
    allow( view ).to receive( :current_user ).and_return( FactoryGirl.build(:user) )
  end

  it "renders the admin-only page" do
    render
    # Check for a specific String presence:
    expect( rendered ).to include( "This should be viewed only by a logged-id User!" )
  end
end
