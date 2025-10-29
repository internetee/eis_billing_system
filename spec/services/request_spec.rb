require 'rails_helper'

RSpec.describe 'Request adapter' do
  class DummyRequester
    include Request
  end

  let(:service) { DummyRequester.new }
  let(:conn_double) { instance_double(Faraday::Connection) }
  let(:response_double) { instance_double(Faraday::Response, body: '{"ok":true}') }

  before do
    allow_any_instance_of(DummyRequester).to receive(:connection).and_return(conn_double)
    allow(conn_double).to receive(:get).and_return(response_double)
    allow(conn_double).to receive(:post).and_return(response_double)
    allow(conn_double).to receive(:put).and_return(response_double)
  end

  it 'performs GET with services options and parses JSON' do
    result = service.get(direction: 'services', path: '/health', params: { ping: 'pong' })
    expect(result).to eq({ 'ok' => true })
    expect(conn_double).to have_received(:get).with('/health', { ping: 'pong' })
  end

  it 'performs POST to everypay with JSON body and parses JSON' do
    result = service.post(direction: 'everypay', path: '/refund', params: { a: 1 })
    expect(result).to eq({ 'ok' => true })
    expect(conn_double).to have_received(:post).with('/refund', JSON.dump({ a: 1 }))
  end

  it 'performs PUT to services with JSON body and parses JSON' do
    result = service.put_request(direction: 'services', path: '/update', params: { b: 2 })
    expect(result).to eq({ 'ok' => true })
    expect(conn_double).to have_received(:put).with('/update', JSON.dump({ b: 2 }))
  end

  describe 'error handling' do
    it 'handles malformed JSON gracefully' do
      malformed_response = instance_double(Faraday::Response, body: 'invalid json')
      allow(conn_double).to receive(:get).and_return(malformed_response)
      
      expect { service.get(direction: 'services', path: '/test') }.to raise_error(JSON::ParserError)
    end

    it 'handles network timeouts' do
      allow(conn_double).to receive(:get).and_raise(Faraday::TimeoutError.new('timeout'))
      
      expect { service.get(direction: 'services', path: '/test') }.to raise_error(Faraday::TimeoutError)
    end
  end
end


