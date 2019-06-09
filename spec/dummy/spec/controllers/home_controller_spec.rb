# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HomeController, type: :controller do
  context 'for an unlogged user,' do
    describe 'GET #index' do
      render_views
      before(:each) do
        get :index
        expect(response).to have_http_status(:success)
      end
      it 'shows the login link' do
        expect(response.body).to include('/users/sign_in')
      end
      it 'shows the sign-up link' do
        expect(response.body).to include('/users/sign_up')
      end
      it 'hides the logout link' do
        expect(response.body).not_to include('/users/sign_out')
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe 'GET #restricted_info' do
      it 'redirects to the login page' do
        get_action_and_check_it_redirects_to_login_for(:restricted_info) # default = user login
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++

  context 'for a logged-in user,' do
    # This will set also a @user instance:
    before(:each) do
      login_user
      expect(@user).to be_a(User)
    end

    describe 'GET #index' do
      render_views
      before(:each) do
        get :index
        expect(response).to have_http_status(:success)
      end
      it 'hides the login link' do
        expect(response.body).not_to include('/users/sign_in')
      end
      it 'hides the sign-up link' do
        expect(response.body).not_to include('/users/sign_up')
      end
      it 'shows the logout link' do
        expect(response.body).to include('/users/sign_out')
      end
    end
    #-- -----------------------------------------------------------------------
    #++

    describe 'GET #restricted_info' do
      render_views
      before(:each) do
        get :restricted_info
        expect(response).to have_http_status(:success)
      end

      # [Steve, 20160918] For Rails 5, assigns & asset_template have been removed
      # since they refer to controller internals and a controller test should not
      # care about these implementation details.
      #      it "assigns a variable @for_user_eyes_only" do
      #        expect( assigns(:for_user_eyes_only) ).to be_an_instance_of( String )
      #        expect( assigns(:for_user_eyes_only) ).to eq("I guess you are a logged-id User!")
      #      end

      it 'shows the current_user email' do
        expect(response.body).to include(@user.email)
      end
    end
    #-- -----------------------------------------------------------------------
    #++
  end
  #-- -------------------------------------------------------------------------
  #++
end
