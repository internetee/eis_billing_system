require 'rails_helper'

RSpec.describe 'EverypayResponse' do
  describe 'sending request to get information about invoice' do
    it 'should get info from everypay by payment reference' do
      uri_object = OpenStruct.new
      uri_object.host = 'http://endpoint/get'
      uri_object.port = '3000'
      uri_object.scheme = 'https'
      uri_object.request_uri = 'request_uri'

      class Net::HTTP::Get
        def initialize(uri)
          @uri = uri
        end

        def basic_auth(username, secret)
          username + ' ' + secret
        end
      end

      class Net::HTTP
        def self.start(arg1, arg2, use_ssl:, verify_mode:)
          yield(self) if block_given?
        end

        def self.request(request)
          response = OpenStruct.new
          response.body = "{ \"this_is\": \"response\"}"

          response
        end
      end

      allow(URI).to receive(:parse).and_return(uri_object)
      allow_any_instance_of(EverypayResponse).to receive(:generate_url).and_return('http://endpoint/get')

      payment_reference = 'some'

      response = EverypayResponse.send_request(payment_reference)

      expect(response).to eq("this_is" => "response")
    end

    it 'should generate url with correct data' do
      api_username = 'api_username'
      payment_reference = 'payment_reference'

      everypay_fetcher = EverypayResponse.new(payment_reference)
      generated_link = everypay_fetcher.generate_url(payment_reference: payment_reference, api_username: api_username)

      expect(generated_link).to eq('https://igw-demo.every-pay.com/api/v4/payments/payment_reference?api_username=api_username')
    end
  end
end
