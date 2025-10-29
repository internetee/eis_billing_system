require 'rails_helper'

RSpec.describe "SessionsController", type: :request do
  describe "GET /new" do
    it "should return success" do
      get sign_in_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE /destroy" do
    let(:user) { create(:user) }
    
    before(:each) do
      allow(Current).to receive(:user).and_return(user)
      allow(Current).to receive(:app_session).and_return(double('app_session'))
      allow_any_instance_of(SessionsController).to receive(:logout).and_return(true)
    end

    it "should log out user and redirect" do
      delete logout_path
      
      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path)
    end

    it "should set flash message on logout" do
      delete logout_path
      
      expect(flash[:success]).to be_present
    end
  end
end

