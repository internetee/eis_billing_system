require 'rails_helper'

RSpec.describe "Api::V1::ImportData::ReferenceData", type: :request do
  describe 'POST /create' do
    before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }

    it 'should import reference data from registry' do
      reference_data = { '_json' => [{
        'reference_number' => '323',
        'initiator' => 'registry'
      }, {
        'reference_number' => '232',
        'initiator' => 'registry'
      }] }

      expect { post api_v1_import_data_reference_data_url, params: reference_data }.to change { Reference.count }.by(2)

      expect(response).to have_http_status(:success)
    end

    it 'should skip if data duplicate' do
      reference_data = { '_json' => [{
        'reference_number' => '333',
        'initiator' => 'registry'
      }, {
        'reference_number' => '333',
        'initiator' => 'registry'
      }] }

      expect { post api_v1_import_data_reference_data_url, params: reference_data }.to change { Reference.count }.by(1)

      expect(Reference.last.initiator).to eq('registry')
      expect(Reference.last.reference_number).to eq('333')
      expect(response).to have_http_status(:success)
    end

    it 'should import invoice data from auction' do
      reference_data = { '_json' => [{
        'reference_number' => '123',
        'initiator' => 'auction'
      }, {
        'reference_number' => '321',
        'initiator' => 'auction'
      }] }

      expect { post api_v1_import_data_reference_data_url, params: reference_data }.to change { Reference.count }.by(2)

      expect(Reference.last.initiator).to eq('auction')
      expect(response).to have_http_status(:success)
    end
  end
end
