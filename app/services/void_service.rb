class VoidService
  include Request
  include ApplicationService

  attr_reader :payment_reference

  def initialize(payment_reference:)
    @payment_reference = payment_reference
  end

  def self.call(payment_reference:)
    new(payment_reference: payment_reference).call
  end

  def call
    contract = VoidContract.new
    result = contract.call(payment_reference: payment_reference)

    puts '-------- VOID SERVICE --------'
    puts result.inspect
    puts '-------- END VOID SERVICE --------'

    if result.success?
      response = base_request
      struct_response(response)
    else
      parse_validation_errors(result)
    end
  end

  private

  def base_request
    uri = URI("#{GlobalVariable::BASE_ENDPOINT}#{GlobalVariable::VOID_ENDPOINT}")
    post(direction: 'everypay', path: uri, params: body)
  end

  def body
    {
      'api_username' => GlobalVariable::API_USERNAME,
      'payment_reference' => payment_reference,
      'nonce' => nonce,
      'timestamp' => "#{Time.zone.now.to_formatted_s(:iso8601)}"
    }
  end

  def nonce
    rand(10**30).to_s.rjust(30, '0')
  end
end
