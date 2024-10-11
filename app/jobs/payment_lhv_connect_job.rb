class PaymentLhvConnectJob < ApplicationJob
  REGEXP = /\A\d{2,20}\z/
  MULTI_REGEXP = /(\d{2,20})/

  REFERENCE_NUMBER_TEST_VALUE = '34443'.freeze
  TRANSACTION_SUM_TEST_VALUE = 100
  INITIATOR = 'billing'.freeze

  def perform
    payment_process
  end

  private

  def api_lhv
    keystore = open_ssl_keystore
    api = Lhv::ConnectApi.new
    api.cert = keystore.certificate
    api.key = keystore.key
    api.dev_mode = ENV['lhv_dev_mode'] == 'true'

    api
  end

  def registry_bank_account_iban = Setting.registry_bank_account_iban_lhv || 'EE177700771001155322'

  def payment_process
    incoming_transactions = []

    api_lhv.credit_debit_notification_messages.each do |message|
      messages_proccess(message, registry_bank_account_iban) do
        message.credit_transactions.each do |credit_transaction|
          if credit_transaction.payment_reference_number.nil?
            credit_transaction.payment_reference_number = parse_reference_number(credit_transaction)

            next if credit_transaction.payment_reference_number.nil?
          end

          next if card_payment_entry?(credit_transaction)

          incoming_transactions << credit_transaction
        end
      end
    end

    sorted_by_ref_number = incoming_transactions.group_by { |x| x[:payment_reference_number] }
    sorted_by_ref_number.each do |s|
      Rails.logger.info '=========== Sending transaction ==========='
      Rails.logger.info s[1]
      Rails.logger.info '==========================================='

      send_transactions(params: s[1], payment_reference_number: s[0])
    end

    Rails.logger.info "Transactions processed: #{incoming_transactions.size}"
  end

  def messages_proccess(message, registry_bank_account_iban, &block)
    Rails.logger.info message
    return unless message.bank_account_iban == registry_bank_account_iban
    return if message.credit_transactions.empty?

    block.call
  end

  def parse_reference_number(credit_transaction)
    reference = ref_number_from_description(credit_transaction.payment_description)
    return unless valid_ref_no?(reference)

    ref = Reference.find_by(reference_number: reference)
    inform_admin(reference:, body: credit_transaction) and return nil if ref.nil?

    reference
  end

  def ref_number_from_description(description)
    matches = description.to_s.scan(Billing::ReferenceNo::MULTI_REGEXP).flatten
    matches.detect { |m| break m if m.length == 7 || valid_ref_no?(m) }
  end

  def valid_ref_no?(match)
    true if Billing::ReferenceNo.valid?(match)
  end

  def inform_admin(reference:, body:)
    Rails.logger.info 'Inform to admin that reference number not found'
    BillingMailer.inform_admin(reference_number: reference, body:).deliver_now
  end

  def open_ssl_keystore
    lhv_keystore_password = ENV['lhv_keystore_password']
    keystore_file = File.read(ENV['lhv_keystore'])
    OpenSSL::PKCS12.new(keystore_file, lhv_keystore_password)
  end

  # https://registry.test/eis_billing/lhv_connect_transactions
  def send_transactions(params:, payment_reference_number:)
    reference = Reference.find_by(reference_number: payment_reference_number)

    uri = URI.parse(url[reference.initiator.to_sym])
    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true
    http.verify_mode = if Rails.env.development? || Rails.env.test?
                         OpenSSL::SSL::VERIFY_NONE # :brakemanignore: SSLVerify
                       else
                         OpenSSL::SSL::VERIFY_PEER
                       end

    res = http.post(url[reference.initiator.to_sym], params.to_json, headers)

    Rails.logger.info '>>>>>>'
    Rails.logger.info res.body
    Rails.logger.info '>>>>>>'
  end

  def generate_token
    JWT.encode(payload, billing_secret)
  end

  def payload
    { initiator: INITIATOR }
  end

  def headers
    {
      'Authorization' => "Bearer #{generate_token}",
      'Content-Type' => 'application/json'
    }
  end

  def url
    {
      registry: registry_url_transaction,
      auction: auction_url_transaction
    }
  end

  def registry_url_transaction
    "#{ENV['base_registry']}/eis_billing/lhv_connect_transactions"
  end

  def auction_url_transaction
    "#{ENV['base_auction']}/eis_billing/lhv_connect_transactions"
  end

  def billing_secret
    ENV['billing_secret']
  end

  def test_transactions
    OpenStruct.new(amount: 0.1,
                   currency: 'EUR',
                   date: Time.zone.today,
                   payment_reference_number: '7366488',
                   payment_description: 'description 7366488')
  end

  def card_payment_entry?(transaction)
    transaction.payment_description.to_s.start_with?('Kaardimaksete tulu')
  end
end
