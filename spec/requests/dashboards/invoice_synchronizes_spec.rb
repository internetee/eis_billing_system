require 'rails_helper'

RSpec.describe "InvoiceSynchronizesController", type: :request do
  let(:user) { create(:user) }
  let(:invoice) { create(:invoice) }
  let(:white_code) { create(:white_code) }

  before(:each) do
    user.reload && white_code.reload

    login user
  end

  describe "POST update invoice status" do
    it 'should notice about successful update' do
      mock_response = {
        'message' => 'Invoice data was successfully updated'
      }
      allow_any_instance_of(InvoiceDataSenderService).to receive(:base_request).and_return(mock_response)

      put dashboards_invoice_synchronize_path(id: invoice.id), headers: {Accept: 'text/vnd.turbo-stream.html'}

      mess = flash[:notice]
      expect(mess).to match 'Invoice data was successfully updated'
    end
  end
end
