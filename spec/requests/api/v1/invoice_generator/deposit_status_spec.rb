require 'rails_helper'

RSpec.describe 'Api::V1::InvoiceGenerator::DepositStatusController', type: :request do
  let(:invoice) { create(:invoice) }

  before(:each) do
    allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true)
    @user_uuid = 'df0ad0b9-8b4e-4946-9562-0a2bb877156c'
    @domain_name = 'deping10.ee'
    @description = "auction_deposit #{@domain_name}, user_uuid #{@user_uuid}, user_email john_doe@test.ee"
  end

  it 'should update status to paid' do
    invoice.update(status: 'unpaid', affiliation: 'auction_deposit', description: @description)
    invoice.reload

    expect(invoice.status).to eq('unpaid')

    params = {
      user_uuid: @user_uuid,
      domain_name: @domain_name,
      status: 'paid'
    }

    post api_v1_invoice_generator_deposit_status_index_path, params: params
    invoice.reload

    expect(invoice.status).to eq('paid')
  end

  it 'should update status to unpaid' do
    invoice.update(status: 'paid', affiliation: 'auction_deposit', description: @description)
    invoice.reload

    expect(invoice.status).to eq('paid')

    params = {
      user_uuid: @user_uuid,
      domain_name: @domain_name,
      status: 'prepayment'
    }

    post api_v1_invoice_generator_deposit_status_index_path, params: params
    invoice.reload

    expect(invoice.status).to eq('unpaid')
  end

  it 'should update status to refunded' do
    invoice.update(status: 'unpaid', affiliation: 'auction_deposit', description: @description)
    invoice.reload

    expect(invoice.status).to eq('unpaid')

    params = {
      user_uuid: @user_uuid,
      domain_name: @domain_name,
      status: 'returned'
    }

    post api_v1_invoice_generator_deposit_status_index_path, params: params
    invoice.reload

    expect(invoice.status).to eq('refunded')
  end

  it 'should notify if status is invalid' do
    invoice.update(status: 'unpaid', affiliation: 'auction_deposit', description: @description)
    invoice.reload

    expect(invoice.status).to eq('unpaid')

    params = {
      user_uuid: @user_uuid,
      domain_name: @domain_name,
      status: 'refunded'
    }

    post api_v1_invoice_generator_deposit_status_index_path, params: params
    invoice.reload

    expect(response.status).to eq 422
    expect(invoice.status).to eq('unpaid')
  end

  it 'should notify if invoice not exists' do
    invoice.update(status: 'unpaid', affiliation: 'auction_deposit', description: @description)
    invoice.reload

    expect(invoice.status).to eq('unpaid')

    params = {
      user_uuid: 'non-existing-uuid',
      domain_name: @domain_name,
      status: 'paid'
    }

    post api_v1_invoice_generator_deposit_status_index_path, params: params
    invoice.reload

    expect(response.status).to eq 422
    expect(JSON.parse(response.body)['error']).to eq 'Invoice with deping10.ee and non-existing-uuid not found in Deposit Status Controller'
    expect(invoice.status).to eq('unpaid')
  end

  it 'should notify if invoice is not auction_deposit' do
    invoice.update(status: 'unpaid', affiliation: 'regular', description: @description)
    invoice.reload

    expect(invoice.status).to eq('unpaid')

    params = {
      user_uuid: @user_uuid,
      domain_name: @domain_name,
      status: 'refunded'
    }

    post api_v1_invoice_generator_deposit_status_index_path, params: params
    invoice.reload

    expect(response.status).to eq 422
    expect(JSON.parse(response.body)['error']).to eq "Invoice with deping10.ee and df0ad0b9-8b4e-4946-9562-0a2bb877156c not found in Deposit Status Controller"
    expect(invoice.status).to eq('unpaid')

  end
end
