require 'rails_helper'

RSpec.describe 'Tara', type: :request do
  let(:user) { create(:user) }
  let(:white_code) { create(:white_code) }

  let(:tara_user_hash) do
    {
      'provider' => 'tara',
      'uid' => 'EE60001019906',
      'info' => {
        'first_name' => 'User',
        'last_name' => 'OmniAuth',
        'name' => 'EE60001019906'
      }
    }
  end

  before(:each) do
    OmniAuth.config.add_mock(:tara, tara_user_hash)
    OmniAuth.config.test_mode = true

    user.reload && white_code.reload
  end

  it 'only user in white list can login' do
    post auth_tara_callback_path(provider: 'tara')

    expect(response.status).to eq 303
  end

  it 'access denied for user not in white list' do
    w = WhiteCode.find_by(code: user.identity_code)
    w.update!(code: '60001019905') && w.reload

    post auth_tara_callback_path(provider: 'tara')

    expect(response.status).to eq 403
  end
end
