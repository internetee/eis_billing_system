require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it "should validate email format" do
      user = User.new(email: "invalid", uid: "EE12345678901", provider: "tara")
      user.valid?
      expect(user.errors[:email]).to include('Invalid email')
    end

    it "should allow nil email" do
      user = User.new(email: nil, uid: "EE12345678901", provider: "tara")
      user.valid?
      expect(user.errors[:email]).to be_empty
    end
  end

  describe "associations" do
    it "should have many app sessions" do
      user = create(:user)
      app_session = create(:app_session, user: user)
      expect(user.app_sessions).to include(app_session)
    end
  end

  describe "#authenticate_session_token" do
    it "should return app session when token is valid" do
      user = create(:user)
      app_session = create(:app_session, user: user)
      
      result = user.authenticate_session_token(app_session.id, app_session.token)
      expect(result).to eq(app_session)
    end

    it "should return nil when session not found" do
      user = create(:user)
      
      result = user.authenticate_session_token(999, "token")
      expect(result).to be_nil
    end
  end

  describe ".from_omniauth" do
    it "should create or find user from omniauth hash" do
      omniauth_hash = {
        'uid' => 'EE60001019906',
        'provider' => 'tara'
      }
      
      user = User.from_omniauth(omniauth_hash)
      expect(user.uid).to eq('EE60001019906')
      expect(user.provider).to eq('tara')
      expect(user.identity_code).to eq('60001019906')
    end
  end
end
