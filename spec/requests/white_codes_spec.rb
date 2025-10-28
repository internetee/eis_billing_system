require 'rails_helper'

RSpec.describe 'WhiteCodes', type: :request do
  let(:user) { create(:user) }
  let(:app_session) { create(:app_session, user: user) }

  before do
    allow(Current).to receive(:user).and_return(user)
    allow(Current).to receive(:app_session).and_return(app_session)
  end

  describe 'GET /white_codes' do
    it 'returns success and assigns white codes' do
      white_code = create(:white_code)
      
      get white_codes_path
      
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /white_codes/new' do
    it 'returns success and assigns new white code' do
      get new_white_code_path
      
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /white_codes/:id/edit' do
    it 'returns success and assigns white code' do
      white_code = create(:white_code)
      
      get edit_white_code_path(white_code)
      
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /white_codes' do
    context 'with valid parameters' do
      it 'creates white code and returns turbo stream' do
        expect {
          post white_codes_path, params: { white_code: { code: '12345678901' } }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.to change(WhiteCode, :count).by(1)
        
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end

    context 'with invalid parameters' do
      it 'does not create white code and returns error' do
        expect {
          post white_codes_path, params: { white_code: { code: '' } }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        }.not_to change(WhiteCode, :count)
        
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end
  end

  describe 'PATCH /white_codes/:id' do
    let(:white_code) { create(:white_code, code: '12345678901') }

    context 'with valid parameters' do
      it 'updates white code and returns turbo stream' do
        patch white_code_path(white_code), params: { white_code: { code: '98765432109' } }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
        expect(white_code.reload.code).to eq('98765432109')
      end
    end

    context 'with invalid parameters' do
      it 'does not update white code and returns error' do
        original_code = white_code.code
        
        patch white_code_path(white_code), params: { white_code: { code: '' } }, headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
        expect(white_code.reload.code).to eq(original_code)
      end
    end
  end

  describe 'DELETE /white_codes/:id' do
    let(:white_code) { create(:white_code, code: '12345678901') }

    context 'when deletion succeeds' do
      it 'deletes white code and returns turbo stream' do
        delete white_code_path(white_code), headers: { 'Accept' => 'text/vnd.turbo-stream.html' }
        
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('text/vnd.turbo-stream.html')
      end
    end

  end
end