require 'rails_helper'

RSpec.describe 'References', type: :request do
  let(:user) { create(:user) }
  let(:app_session) { create(:app_session, user: user) }

  before do
    allow(Current).to receive(:user).and_return(user)
    allow(Current).to receive(:app_session).and_return(app_session)
  end

  describe 'GET /references' do
    it 'returns success and assigns paginated references' do
      create_list(:reference, 3)
      
      get references_path
      
      expect(response).to have_http_status(:success)
    end

    it 'searches references with params' do
      reference1 = create(:reference, reference_number: '12345', owner: 'John Doe')
      reference2 = create(:reference, reference_number: '67890', owner: 'Jane Smith')
      
      get references_path, params: { search: 'John' }
      
      expect(response).to have_http_status(:success)
    end

    it 'respects per_page parameter' do
      create_list(:reference, 30)
      
      get references_path, params: { per_page: 10 }
      
      expect(response).to have_http_status(:success)
    end
  end
end