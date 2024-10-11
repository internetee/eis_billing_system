require 'rails_helper'

RSpec.describe 'PaymentLhvConnectJob', type: :job do
  before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end

  let(:invoice) { build(:invoice) }
  let(:reference) { create(:reference) }

  describe '#perform later' do
    it 'get transactions' do
      ActiveJob::Base.queue_adapter = :test
      expect do
        PaymentLhvConnectJob.perform_later
      end.to have_enqueued_job
    end
  end

  describe 'notify about status of transactions' do
    it 'should notify initiator about incoming payments' do
      Reference.create(reference_number: 2, initiator: 'registry')

      date = Time.zone.now - 4.hours
      params_for_sending = OpenStruct.new(amount: '10.0', currency: 'EUR', date: date, payment_reference_number: '2',
                                          payment_description: 'Money comes from 1')

      Lhv::ConnectApi.class_eval do
        define_method :credit_debit_notification_messages do
          transaction = OpenStruct.new(amount: '10.0',
                                       currency: 'EUR',
                                       date: date,
                                       payment_reference_number: '2',
                                       payment_description: 'Money comes from 1')
          message = OpenStruct.new(bank_account_iban: Setting.registry_bank_account_iban_lhv || 'EE177700771001155322',
                                   credit_transactions: [transaction])
          [message]
        end
      end
      openssl_struct = OpenStruct.new(key: 'key', certificate: 'certificate')

      uri_object = OpenStruct.new
      uri_object.host = 'http://endpoint/get'
      uri_object.port = '3000'
      allow(URI).to receive(:parse).and_return(uri_object)
      # allow(OpenSSL::PKCS12).to receive(:new).and_return('path_to_file')

      allow_any_instance_of(Net::HTTP).to receive(:post).and_return('200 - ok')
      allow_any_instance_of(PaymentLhvConnectJob).to receive(:open_ssl_keystore).and_return(openssl_struct)

      expect_any_instance_of(PaymentLhvConnectJob).to receive(:send_transactions).with(params: [params_for_sending], payment_reference_number: '2')
      PaymentLhvConnectJob.perform_now
    end

    it 'should send nothing if no any incoming transactions were made' do
      Lhv::ConnectApi.class_eval do
        define_method :credit_debit_notification_messages do
          []
        end
      end

      openssl_struct = OpenStruct.new(key: 'key', certificate: 'certificate')
      allow_any_instance_of(PaymentLhvConnectJob).to receive(:open_ssl_keystore).and_return(openssl_struct)

      expect_any_instance_of(PaymentLhvConnectJob).not_to receive(:send_transactions).with(params: [], payment_reference_number: nil)
      PaymentLhvConnectJob.perform_now
    end
  end

  describe 'parsing payment description' do
    before(:each) do
      openssl_struct = OpenStruct.new(key: 'key', certificate: 'certificate')

      uri_object = OpenStruct.new
      uri_object.host = 'http://endpoint/get'
      uri_object.port = '3000'
      allow(URI).to receive(:parse).and_return(uri_object)

      allow_any_instance_of(Net::HTTP).to receive(:post).and_return('200 - ok')
      allow_any_instance_of(PaymentLhvConnectJob).to receive(:open_ssl_keystore).and_return(openssl_struct)

      # reference.reload
    end

    it 'reference number is missing, but payment description has valid reference number' do
      ref = Billing::ReferenceNo.generate
      Reference.create(reference_number: ref, initiator: 'registry')

      date = Time.zone.now - 4.hours
      params_for_sending = OpenStruct.new(amount: '10.0', currency: 'EUR', date: date, payment_reference_number: ref,
                                          payment_description: "Money comes from #{ref}")

      Lhv::ConnectApi.class_eval do
        define_method :credit_debit_notification_messages do
          transaction = OpenStruct.new(amount: '10.0',
                                       currency: 'EUR',
                                       date: date,
                                       payment_reference_number: nil,
                                       payment_description: "Money comes from #{ref}")
          message = OpenStruct.new(bank_account_iban: Setting.registry_bank_account_iban_lhv || 'EE177700771001155322',
                                   credit_transactions: [transaction])
          [message]
        end
      end

      expect_any_instance_of(PaymentLhvConnectJob).to receive(:send_transactions).with(params: [params_for_sending], payment_reference_number: ref)
      PaymentLhvConnectJob.perform_now
    end

    it 'should skip card payment entries' do
      date = Time.zone.now - 4.hours
      card_payment = OpenStruct.new(
        amount: '20.74',
        currency: 'EUR',
        date: date,
        payment_reference_number: nil,
        payment_description: 'Kaardimaksete tulu 24.09.2024'
      )
      regular_payment = OpenStruct.new(
        amount: '10.0',
        currency: 'EUR',
        date: date,
        payment_reference_number: '123',
        payment_description: 'Regular payment'
      )

      Lhv::ConnectApi.class_eval do
        define_method :credit_debit_notification_messages do
          message = OpenStruct.new(
            bank_account_iban: Setting.registry_bank_account_iban_lhv || 'EE177700771001155322',
            credit_transactions: [card_payment, regular_payment]
          )
          [message]
        end
      end

      openssl_struct = OpenStruct.new(key: 'key', certificate: 'certificate')
      allow_any_instance_of(PaymentLhvConnectJob).to receive(:open_ssl_keystore).and_return(openssl_struct)

      expect_any_instance_of(PaymentLhvConnectJob).to receive(:send_transactions).with(
        params: [regular_payment],
        payment_reference_number: '123'
      )
      PaymentLhvConnectJob.perform_now
    end
  end
end
