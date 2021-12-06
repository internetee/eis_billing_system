require 'rails_helper'

RSpec.describe "Api::V1::CallbackHandler::CallbackHandlers", type: :request do
  describe "GET /callback" do
    it "returns http success" do
      get "/api/v1/callback_handler/callback_handler/callback"
      expect(response).to have_http_status(:success)
    end
  end

end
