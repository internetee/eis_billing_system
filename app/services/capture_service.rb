class CaptureService
  include Request
  include ApplicationService
  include ActionView::Helpers::NumberHelper

  attr_reader :amount, :payment_reference

  def initialize(amount:, payment_reference:)
    @amount = amount
    @payment_reference = payment_reference
  end

  def self.call(amount:, payment_reference:)
    new(amount:, payment_reference:).call
  end

  def call
    contract = CaptureContract.new
    result = contract.call(amount:, payment_reference:)

    if result.success?
      response = base_request
      struct_response(response)
    else
      parse_validation_errors(result)
    end
  end

  private

  def base_request
    uri = URI("#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::CAPTURE_ENDPOINT}")
    post(direction: 'everypay', path: uri, params: body)
  end

  def body
    {
      'api_username' => GlobalVariable::API_USERNAME,
      'amount' => number_with_precision(amount, precision: 2),
      'payment_reference' => payment_reference,
      'nonce' => nonce,
      'timestamp' => "#{Time.zone.now.to_formatted_s(:iso8601)}"
    }
  end

  def nonce
    rand(10**30).to_s.rjust(30, '0')
  end
end
