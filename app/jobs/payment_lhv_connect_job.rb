class PaymentLhvConnectJob < ApplicationJob
  REGEXP = /\A\d{2,20}\z/
  MULTI_REGEXP = /(\d{2,20})/

  REFERENCE_NUMBER_TEST_VALUE = '34443'.freeze
  TRANSACTION_SUM_TEST_VALUE = 100

  def perform(test: true)
    if test
      test_payment(name: 'Oleg', reference_no: REFERENCE_NUMBER_TEST_VALUE, transaction_amount: TRANSACTION_SUM_TEST_VALUE)
    else
      payment_preocess
    end
  end

  private

  def payment_preocess
    # registry_bank_account_iban = Setting.registry_iban
    registry_bank_account_iban = "EE557700771000598731"
    lhv_keystore_password = 'testtest'

    # keystore = OpenSSL::PKCS12.new(File.read(ENV['lhv_p12_keystore']), ENV['lhv_keystore_password'])
    keystore = OpenSSL::PKCS12.new(File.read('./keystore.p12'), lhv_keystore_password)

    key = keystore.key
    cert = keystore.certificate

    api = Lhv::ConnectApi.new
    api.cert = cert
    api.key = key
    # api.ca_file = ENV['lhv_ca_file']
    # api.dev_mode = ENV['lhv_dev_mode'] == 'true'

    incoming_transactions = []

    api.credit_debit_notification_messages.each do |message|
      next unless message.bank_account_iban == registry_bank_account_iban

      message.credit_transactions.each do |credit_transaction|
        incoming_transactions << credit_transaction
      end
    end

    process_transactions(incoming_transactions)

    puts "Transactions processed: #{incoming_transactions.size}"
  end

  def test_payment(name:, reference_no:, transaction_amount:)
    user = OpenStruct.new(id: 1, name: name, reference_number: reference_no)

    return make_some_action_if_user_is_nil if user.nil?

    transactions = [OpenStruct.new(amount: transaction_amount,
                                   currency: 'EUR',
                                   date: Time.zone.today,
                                   payment_reference_number: user.reference_number,
                                   payment_description: "description #{user.reference_number}")]

    process_transactions(transactions)
    puts 'Last registrar invoice is'
  end

  def log(msg)
    @log ||= Logger.new($stdout)
    @log.info(msg)
  end

  def process_transactions(incoming_transactions)
    if incoming_transactions.any?
      log 'Got incoming transactions'
      log incoming_transactions

      # bank_statement = BankStatement.new(bank_code: Setting.registry_bank_code,
      #                                    iban: Setting.registry_iban)
      bank_statement = BankStatement.new(bank_code: '689',
                                         iban: 'EE557700771000598731')

      ActiveRecord::Base.transaction do
        bank_statement.save!

        incoming_transactions.each do |incoming_transaction|
          transaction_attributes = { sum: incoming_transaction.amount,
                                     currency: incoming_transaction.currency,
                                     paid_at: incoming_transaction.date,
                                     reference_no: incoming_transaction.payment_reference_number,
                                     description: incoming_transaction.payment_description }
          transaction = bank_statement.bank_transactions.create!(transaction_attributes)

          search_and_update_invoice(transaction)
        end
      end
    else
      log 'Got no incoming transactions parsed, aborting'
    end
  end

  def search_and_update_invoice(transaction)
    ref_number = parsed_ref_number(transaction)
    invoice = Invoice.find_by(reference_number: ref_number, transaction_amount: transaction.sum.to_i)

    return make_some_action_if_invoice_not_found(transaction) if invoice.nil?

    invoice.update(status: :paid)
  end

  def parsed_ref_number(transaction)
    transaction.reference_no || ref_number_from_description(transaction)
  end

  def ref_number_from_description(transaction)
    matches = transaction.description.to_s.scan(MULTI_REGEXP).flatten
    matches.detect { |m| break m if m.length == 7 || valid_ref_no?(m) }
  end

  def make_some_action_if_user_is_nil
    log 'USER NOT FOUND BRO'
  end

  def make_some_action_if_invoice_not_found(transaction)
    log 'INVOICE NOT FOUND'
    log 'So, I will create it by myself then !!!!'

    ref_number = parsed_ref_number(transaction)
    user = User.find_by(reference_number: ref_number)

    return make_some_action_if_user_is_nil if user.nil?

    Invoice.create(
      invoice_number: '000',
      description: 'Direct top-up via bank transfer',
      transaction_amount: transaction.sum,
      customer_name: user.name,
      customer_email: user.email,
      order_reference: nil,
      reference_number: ref_number,
      status: 3
    )
  end
end
