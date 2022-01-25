class PaymentLhvConnectJob < ApplicationJob
  REGEXP = /\A\d{2,20}\z/
  MULTI_REGEXP = /(\d{2,20})/

  REFERENCE_NUMBER_TEST_VALUE = '34443'.freeze
  TRANSACTION_SUM_TEST_VALUE = 100

  def perform(test: true)
    payment_process(test: test)
  end

  private

  def payment_process(test:)
    registry_bank_account_iban = "EE177700771001155322"
    lhv_keystore_password = ENV['lhv_keystore_password']

    keystore = OpenSSL::PKCS12.new(File.read(ENV['lhv_keystore']), lhv_keystore_password)

    key = keystore.key
    cert = keystore.certificate

    api = Lhv::ConnectApi.new
    api.cert = cert
    api.key = key
    api.ca_file = ENV['lhv_ca_file']
    api.dev_mode = ENV['lhv_dev_mode'] == 'true'

    incoming_transactions = []

    if test
      3.times do
        incoming_transactions << test_transactions
      end
    else
      api.credit_debit_notification_messages.each do |message|
        next unless message.bank_account_iban == registry_bank_account_iban

        message.credit_transactions.each do |credit_transaction|
          incoming_transactions << credit_transaction
        end
      end
    end

    send_transactions_to_registry(params: incoming_transactions)
    puts "Transactions processed: #{incoming_transactions.size}"
  end

  # https://registry.test/eis_billing/lhv_connect_transactions
  def send_transactions_to_registry(params:)
    uri = URI.parse(url_transaction)
    http = Net::HTTP.new(uri.host, uri.port)
    headers = {
      'Authorization'=>'Bearer foobar',
      'Content-Type' =>'application/json'
      # 'Accept'=> TOKEN
    }

    res = http.post(url_transaction, params.to_json, headers)
    res
  end

  def url_transaction
    "#{ENV['base_registry']}/eis_billing/lhv_connect_transactions"
  end

  def test_transactions
    OpenStruct.new(amount: 0.1,
                   currency: 'EUR',
                   date: Time.zone.today,
                   payment_reference_number: '2199812',
                   payment_description: "description 2199812")
  end

  def log(msg)
    @log ||= Logger.new($stdout)
    @log.info(msg)
  end
end
