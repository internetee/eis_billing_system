require 'rails_helper'

RSpec.describe "Everypays", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/everypay/index"
      expect(response).to have_http_status(:success)
    end
  end

end
