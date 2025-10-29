require 'rails_helper'

RSpec.describe "ErrorsController", type: :request do
  describe "GET /show" do
    it "should exist as a controller" do
      expect(ErrorsController).to be_present
    end
  end
end

