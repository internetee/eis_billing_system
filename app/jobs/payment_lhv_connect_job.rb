class PaymentLhvConnectJob < ApplicationJob
  REGEXP = /\A\d{2,20}\z/
  MULTI_REGEXP = /(\d{2,20})/

  REFERENCE_NUMBER_TEST_VALUE = '34443'.freeze
  TRANSACTION_SUM_TEST_VALUE = 100

  def perform
    payment_process
  end

  private

  def payment_process
    registry_bank_account_iban = Setting.registry_bank_account_iban_lhv || 'EE177700771001155322'

    keystore = open_ssl_keystore
    key = keystore.key
    cert = keystore.certificate

    api = Lhv::ConnectApi.new
    api.cert = cert
    api.key = key
    # api.ca_file = ENV['lhv_ca_file']
    api.dev_mode = ENV['lhv_dev_mode'] == 'true'

    incoming_transactions = []

    api.credit_debit_notification_messages.each do |message|
      Rails.logger.info message

      next unless message.bank_account_iban == registry_bank_account_iban

      next if message.credit_transactions.empty?

      message.credit_transactions.each do |credit_transaction|
        incoming_transactions << credit_transaction
      end
    end

    sorted_by_ref_number = incoming_transactions.group_by { |x| x[:payment_reference_number] }
    sorted_by_ref_number.each do |s|
      reference_initiator = Reference.find_by(reference_number: s[0])

      if reference_initiator.initiator == 'registry'
        send_transactions_to_registry(params: s[1])
      else
        p reference_initiator.initiator
        p s[1]
      end
    end

    # send_transactions_to_registry(params: incoming_transactions)
    puts "Transactions processed: #{incoming_transactions.size}"
  end

  def open_ssl_keystore
    lhv_keystore_password = ENV['lhv_keystore_password']
    keystore_file = File.read(ENV['lhv_keystore'])
    OpenSSL::PKCS12.new(keystore_file, lhv_keystore_password)
  end

  # https://registry.test/eis_billing/lhv_connect_transactions
  def send_transactions_to_registry(params:)
    uri = URI.parse(url_transaction)
    http = Net::HTTP.new(uri.host, uri.port)

    res = http.post(url_transaction, params.to_json, headers)

    res
  end

  def generate_token
    JWT.encode(payload, ENV['secret_word'])
  end

  def payload
    { data: GlobalVariable::SECRET_WORD }
  end

  def headers 
    {
    'Authorization' => "Bearer #{generate_token}",
    'Content-Type' => 'application/json',
    }
  end

  def url_transaction
    return "#{ENV['base_registry_dev']}/eis_billing/lhv_connect_transactions" if Rails.env.development?

    "#{ENV['base_registry_staging']}/eis_billing/lhv_connect_transactions"
  end

  def test_transactions
    OpenStruct.new(amount: 0.1,
                   currency: 'EUR',
                   date: Time.zone.today,
                   payment_reference_number: '7366488',
                   payment_description: "description 7366488")
  end

  def log(msg)
    @log ||= Logger.new($stdout)
    @log.info(msg)
  end
end
