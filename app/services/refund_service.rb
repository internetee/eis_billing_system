class RefundService
  include Request
  include ApplicationService
  include ActionView::Helpers::NumberHelper 

  attr_reader :amount, :payment_reference, :timestamp

  def initialize(amount:, payment_reference:, timestamp:)
    @amount = amount
    @payment_reference = payment_reference
    @timestamp = timestamp
  end

  def self.call(amount:, payment_reference:, timestamp:)
    new(amount: amount, payment_reference: payment_reference, timestamp: timestamp).call
  end

  def call
    contract = RefundContract.new
    result = contract.call(amount: amount, payment_reference: payment_reference, timestamp: timestamp)

    if result.success?
      response = base_request
      struct_response(response)
    else
      parse_validation_errors(result)
    end
  end

  private

  def base_request
    uri = URI("#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::REFUND_ENDPOINT}")
    post(direction: 'everypay', path: uri, params: body)
  end

  def body
    {
      'api_username' => GlobalVariable::API_USERNAME,
      'amount' => number_with_precision(amount, precision: 2),
      'payment_reference' => payment_reference,
      'nonce' => nonce,
      'timestamp' => timestamp
    }
  end

  def nonce
    rand(10**30).to_s.rjust(30, '0')
  end
end
