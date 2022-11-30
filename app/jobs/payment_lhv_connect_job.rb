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
        if credit_transaction.payment_reference_number.nil?
          reference = ref_number_from_description(credit_transaction.payment_description)
          next unless valid_ref_no?(reference)

          ref = Reference.find_by(reference_number: reference)

          if ref.nil?
            inform_admin(reference)

            next
          end

          credit_transaction.payment_reference_number = reference
          incoming_transactions << credit_transaction
        end

        incoming_transactions << credit_transaction
      end
    end

    sorted_by_ref_number = incoming_transactions.group_by { |x| x[:payment_reference_number] }
    sorted_by_ref_number.each do |s|
      Rails.logger.info "=========== Sending to registry ==========="
      Rails.logger.info s[1]
      Rails.logger.info "==========================================="

      send_transactions_to_registry(params: s[1])
    end

    Rails.logger.info "Transactions processed: #{incoming_transactions.size}"
  end

  def inform_admin(reference_number)
    Rails.logger.info "Inform to admin that reference number not found"
    BillingMailer.inform_admin(reference_number: reference_number).deliver_now
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

    unless Rails.env.development? || Rails.env.test?
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    res = http.post(url_transaction, params.to_json, headers)

    Rails.logger.info ">>>>>>"
    Rails.logger.info res.body
    Rails.logger.info ">>>>>>"
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
    'Content-Type' => 'application/json',
    }
  end

  def url_transaction
    "#{ENV['base_registry']}/eis_billing/lhv_connect_transactions"
  end

  def billing_secret
    ENV['billing_secret']
  end

  def test_transactions
    OpenStruct.new(amount: 0.1,
                   currency: 'EUR',
                   date: Time.zone.today,
                   payment_reference_number: '7366488',
                   payment_description: "description 7366488")
  end

  def ref_number_from_description(description)
    matches = description.to_s.scan(Billing::ReferenceNo::MULTI_REGEXP).flatten
    matches.detect { |m| break m if m.length == 7 || valid_ref_no?(m) }
  end

  def valid_ref_no?(match)
    return true if Billing::ReferenceNo.valid?(match)
  end
end
