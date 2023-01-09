require 'rails_helper'

RSpec.describe "Api::V1::Invoice::InvoiceSynchronizeController", type: :request do
  let(:invoice) { create(:invoice) }

  before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }

  it 'should successfully send invoice data to the initiator service' do
    mock_response = {
      'message' => 'Invoice data was successfully updated'
    }
    allow_any_instance_of(InvoiceDataSenderService).to receive(:base_request).and_return(mock_response)

    patch api_v1_invoice_invoice_synchronize_path(id: invoice.id)

    message = JSON.parse(response.body).with_indifferent_access[:message]
    expect(message).to match 'Invoice data was successfully updated'
    expect(response.status).to eq 200
  end

  it 'should return an error if something went wrong' do
    mock_response = {
      'error' => {
        'message' => 'Something went wrong'
      }
    }
    allow_any_instance_of(InvoiceDataSenderService).to receive(:base_request).and_return(mock_response)

    patch api_v1_invoice_invoice_synchronize_path(id: invoice.id)

    message = JSON.parse(response.body).with_indifferent_access[:error]

    expect(message).to match 'Something went wrong'
    expect(response.status).to eq 422
  end
end
