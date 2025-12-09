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

    it 'should skip card payment entries and auction portal payments' do
      date = Time.zone.now - 4.hours
      card_payment = OpenStruct.new(
        amount: '20.74',
        currency: 'EUR',
        date: date,
        payment_reference_number: nil,
        payment_description: 'Kaardimaksete tulu 24.09.2024'
      )
      auction_payment = OpenStruct.new(
        amount: '123.0',
        currency: 'EUR',
        date: date,
        payment_reference_number: nil,
        payment_description: 'billing.internet.ee/EE, st994341, Ref:11111, 140001, 140002'
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
            credit_transactions: [card_payment, auction_payment, regular_payment]
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

    it 'should skip card payment entries, auction portal payments, and account interest entries' do
      date = Time.zone.now - 4.hours
      card_payment = OpenStruct.new(
        amount: '20.74',
        currency: 'EUR',
        date: date,
        payment_reference_number: nil,
        payment_description: 'Kaardimaksete tulu 24.09.2024'
      )
      auction_payment = OpenStruct.new(
        amount: '123.0',
        currency: 'EUR',
        date: date,
        payment_reference_number: nil,
        payment_description: 'billing.internet.ee/EE, st994341, Ref:11111, 140001, 140002'
      )
      account_interest = OpenStruct.new(
        amount: '1.0',
        currency: 'EUR',
        date: date,
        payment_reference_number: nil,
        payment_description: 'Konto intress EE557700771000598731, 01.09.2024 - 30.09.2024, intressimäär 1.00%.'
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
            credit_transactions: [card_payment, auction_payment, account_interest, regular_payment]
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

    it 'should find reference number in end_to_end_id when not found in payment description' do
      ref = Billing::ReferenceNo.generate
      Reference.create(reference_number: ref, initiator: 'registry')

      date = Time.zone.now - 4.hours
      params_for_sending = OpenStruct.new(
        amount: '10.0', 
        currency: 'EUR', 
        date: date, 
        payment_reference_number: ref,
        payment_description: 'Money transfer without reference',
        end_to_end_id: ref
      )

      Lhv::ConnectApi.class_eval do
        define_method :credit_debit_notification_messages do
          transaction = OpenStruct.new(
            amount: '10.0',
            currency: 'EUR',
            date: date,
            payment_reference_number: nil,
            payment_description: 'Money transfer without reference',
            end_to_end_id: ref
          )
          message = OpenStruct.new(
            bank_account_iban: Setting.registry_bank_account_iban_lhv || 'EE177700771001155322',
            credit_transactions: [transaction]
          )
          [message]
        end
      end

      expect_any_instance_of(PaymentLhvConnectJob).to receive(:send_transactions).with(
        params: [params_for_sending], 
        payment_reference_number: ref
      )
      PaymentLhvConnectJob.perform_now
    end

    it 'should not process transaction when end_to_end_id is present but not in database' do
      invalid_ref = '12345678'
      date = Time.zone.now - 4.hours

      Lhv::ConnectApi.class_eval do
        define_method :credit_debit_notification_messages do
          transaction = OpenStruct.new(
            amount: '10.0',
            currency: 'EUR',
            date: date,
            payment_reference_number: nil,
            payment_description: 'Money transfer without valid reference',
            end_to_end_id: invalid_ref
          )
          message = OpenStruct.new(
            bank_account_iban: Setting.registry_bank_account_iban_lhv || 'EE177700771001155322',
            credit_transactions: [transaction]
          )
          [message]
        end
      end

      expect_any_instance_of(BillingMailer).to receive(:inform_admin).with(
        reference_number: invalid_ref, 
        body: an_instance_of(OpenStruct)
      ).and_return(double("mailer", deliver_now: true))
      
      expect_any_instance_of(PaymentLhvConnectJob).not_to receive(:send_transactions)
      PaymentLhvConnectJob.perform_now
    end

    it 'should not process transaction when neither payment description nor end_to_end_id contain valid reference' do
      date = Time.zone.now - 4.hours

      Lhv::ConnectApi.class_eval do
        define_method :credit_debit_notification_messages do
          transaction = OpenStruct.new(
            amount: '10.0',
            currency: 'EUR',
            date: date,
            payment_reference_number: nil,
            payment_description: 'Money transfer without any reference',
            end_to_end_id: nil
          )
          message = OpenStruct.new(
            bank_account_iban: Setting.registry_bank_account_iban_lhv || 'EE177700771001155322',
            credit_transactions: [transaction]
          )
          [message]
        end
      end

      expect_any_instance_of(BillingMailer).to receive(:inform_admin).with(
        reference_number: nil,
        body: an_instance_of(OpenStruct)
      ).and_return(double("mailer", deliver_now: true))

      expect_any_instance_of(PaymentLhvConnectJob).not_to receive(:send_transactions)
      PaymentLhvConnectJob.perform_now
    end

    it 'should parse reference number from end_to_end_id with text prefix like "Ref 1234567"' do
      ref = Billing::ReferenceNo.generate
      Reference.create(reference_number: ref, initiator: 'registry')

      date = Time.zone.now - 4.hours
      end_to_end_with_text = "Ref #{ref}"

      params_for_sending = OpenStruct.new(
        amount: '10.0',
        currency: 'EUR',
        date: date,
        payment_reference_number: ref,
        payment_description: 'Money transfer',
        end_to_end_id: end_to_end_with_text
      )

      Lhv::ConnectApi.class_eval do
        define_method :credit_debit_notification_messages do
          transaction = OpenStruct.new(
            amount: '10.0',
            currency: 'EUR',
            date: date,
            payment_reference_number: nil,
            payment_description: 'Money transfer',
            end_to_end_id: end_to_end_with_text
          )
          message = OpenStruct.new(
            bank_account_iban: Setting.registry_bank_account_iban_lhv || 'EE177700771001155322',
            credit_transactions: [transaction]
          )
          [message]
        end
      end

      expect_any_instance_of(PaymentLhvConnectJob).to receive(:send_transactions).with(
        params: [params_for_sending],
        payment_reference_number: ref
      )
      PaymentLhvConnectJob.perform_now
    end

    it 'should parse reference number from end_to_end_id with various text formats' do
      ref = Billing::ReferenceNo.generate
      Reference.create(reference_number: ref, initiator: 'registry')

      date = Time.zone.now - 4.hours
      end_to_end_with_text = "Reference: #{ref} payment"

      params_for_sending = OpenStruct.new(
        amount: '10.0',
        currency: 'EUR',
        date: date,
        payment_reference_number: ref,
        payment_description: 'Money transfer',
        end_to_end_id: end_to_end_with_text
      )

      Lhv::ConnectApi.class_eval do
        define_method :credit_debit_notification_messages do
          transaction = OpenStruct.new(
            amount: '10.0',
            currency: 'EUR',
            date: date,
            payment_reference_number: nil,
            payment_description: 'Money transfer',
            end_to_end_id: end_to_end_with_text
          )
          message = OpenStruct.new(
            bank_account_iban: Setting.registry_bank_account_iban_lhv || 'EE177700771001155322',
            credit_transactions: [transaction]
          )
          [message]
        end
      end

      expect_any_instance_of(PaymentLhvConnectJob).to receive(:send_transactions).with(
        params: [params_for_sending],
        payment_reference_number: ref
      )
      PaymentLhvConnectJob.perform_now
    end
  end

  describe '#extract_reference_from_text' do
    let(:job) { PaymentLhvConnectJob.new }

    before do
      allow(Billing::ReferenceNo).to receive(:valid?).and_call_original
    end

    it 'returns text as-is when it is already a pure reference number' do
      ref = Billing::ReferenceNo.generate
      result = job.send(:extract_reference_from_text, ref)
      expect(result).to eq(ref)
    end

    it 'extracts reference number from "Ref 1234567" format' do
      ref = Billing::ReferenceNo.generate
      result = job.send(:extract_reference_from_text, "Ref #{ref}")
      expect(result).to eq(ref)
    end

    it 'extracts reference number from text with prefix and suffix' do
      ref = Billing::ReferenceNo.generate
      result = job.send(:extract_reference_from_text, "Reference: #{ref} payment")
      expect(result).to eq(ref)
    end

    it 'returns nil for text without any numbers' do
      result = job.send(:extract_reference_from_text, 'No numbers here')
      expect(result).to be_nil
    end

    it 'returns nil for empty string' do
      result = job.send(:extract_reference_from_text, '')
      expect(result).to be_nil
    end

    it 'returns nil for nil input' do
      result = job.send(:extract_reference_from_text, nil)
      expect(result).to be_nil
    end

    it 'extracts 7-digit reference number from text' do
      result = job.send(:extract_reference_from_text, 'Ref 1234567')
      expect(result).to eq('1234567')
    end

    it 'finds valid reference number among multiple numbers in text' do
      ref = Billing::ReferenceNo.generate
      result = job.send(:extract_reference_from_text, "Invoice 99 ref #{ref} amount 100")
      expect(result).to eq(ref)
    end
  end
end
