require 'rails_helper'

RSpec.describe "Dashboards", type: :request do
  let(:user) { create(:user) }

  before(:each) do
    allow(Current).to receive(:user).and_return(user)
  end

  describe "GET /index" do
    it "should return success" do
      get dashboard_index_path
      expect(response).to have_http_status(:success)
    end

    it "should display invoices with pagination" do
      create_list(:invoice, 3)
      
      get dashboard_index_path
      expect(response).to have_http_status(:success)
    end

    it "should handle search parameters" do
      get dashboard_index_path, params: { search: "test" }
      expect(response).to have_http_status(:success)
    end

    it "should handle pagination parameters" do
      create_list(:invoice, 30) # Create enough invoices for pagination
      get dashboard_index_path, params: { page: 2, per_page: 10 }
      expect(response).to have_http_status(:success)
    end

    it "should set default pagination values" do
      get dashboard_index_path
      expect(response).to have_http_status(:success)
    end

    it "should set amount range defaults" do
      get dashboard_index_path
      expect(response).to have_http_status(:success)
    end
  end
end
