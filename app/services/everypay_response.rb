class EverypayResponse
  include Request

  attr_reader :payment_reference

  def initialize(payment_reference)
    @payment_reference = payment_reference
  end

  def self.send_request(payment_reference)
    fetcher = new(payment_reference)

    uri = fetcher.generate_url(payment_reference: payment_reference)
    fetcher.base_request(uri: uri)
  end

  def generate_url(payment_reference:)
    "#{GlobalVariable::BASE_ENDPOINT}/payments/#{payment_reference}?api_username=#{GlobalVariable::API_USERNAME}"
  end

  def base_request(uri:)
    get(direction: 'everypay', path: uri)
  end
end
