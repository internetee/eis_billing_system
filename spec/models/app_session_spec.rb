require 'rails_helper'

RSpec.describe AppSession, type: :model do
  describe "associations" do
    it "should belong to user" do
      user = create(:user)
      app_session = create(:app_session, user: user)
      expect(app_session.user).to eq(user)
    end
  end

  describe "callbacks" do
    it "should generate token before creation" do
      user = create(:user)
      app_session = AppSession.new(user: user)
      
      expect(app_session.token).to be_nil
      app_session.save
      expect(app_session.token).to be_present
    end
  end

  describe "#to_h" do
    it "should return hash with user_id, app_session, and token" do
      user = create(:user)
      app_session = create(:app_session, user: user)
      
      expect(app_session.to_h).to include(
        user_id: user.id,
        app_session: app_session.id,
        token: app_session.token
      )
    end
  end
end
