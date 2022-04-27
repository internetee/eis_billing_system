require 'rails_helper'

RSpec.describe "ApplicationController", type: :controller do
  describe "Authentication Headers" do
    it "should return from authorization header value" do
      instance = ApplicationController.new
      request = OpenStruct.new
      request.headers = {'Authorization': 'Bearer auth'}

      expect_any_instance_of(ApplicationController).to receive(:auth_header).and_return(request.headers)

      expect(instance.auth_header).to eq({'Authorization': 'Bearer auth'})
    end

    it 'should return billing secret' do
      stub_const('ENV', { 'billing_secret' => 'secret' })
      instance = ApplicationController.new

      expect(instance.billing_secret_key).to eq('secret')
    end

    it 'should encode payload by billing secret' do
      stub_const('ENV', { 'billing_secret' => 'secret' })
      instance = ApplicationController.new
      payload = {
        data: 'test'
      }

      expect(instance.encode_token(payload)).to match('eyJhbGciOiJIUzI1NiJ9.eyJkYXRhIjoidGVzdCJ9.pVzcY2dX8JNM3LzIYeP2B1e1Wcpt1K3TWVvIYSF4x-o')
    end

    it 'should decode incoming token' do
      stub_const('ENV', { 'billing_secret' => 'secret' })
      instance = ApplicationController.new
      request = OpenStruct.new
      request.headers = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJpbml0aWF0b3IiOiJ0ZXN0In0.IIjSNs6gOigBcBpssTCBGtWDZSkRYs0UDk15y6b5h1M'
      allow_any_instance_of(ApplicationController).to receive(:auth_header).and_return(request.headers)

      decoded_result = instance.decoded_token
      expect(decoded_result[0]['initiator']).to eq('test')
    end

    it 'should authorized if initiator registry exist' do
      stub_const('ENV', { 'billing_secret' => 'secret' })
      instance = ApplicationController.new
      request = OpenStruct.new
      request.headers = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJpbml0aWF0b3IiOiJyZWdpc3RyeSJ9.oq2EX0KvKrMrH6aUFIzDjmO6ZhYf_DFE9fpx2DhYonI'
      allow_any_instance_of(ApplicationController).to receive(:auth_header).and_return(request.headers)

      expect(instance.logged_in?).to be_truthy
    end

    # JWT.encode({initiator: 'registry' }, 'secret')

    it 'should authorized if initiator auction exist' do
      stub_const('ENV', { 'billing_secret' => 'secret' })
      instance = ApplicationController.new
      request = OpenStruct.new
      request.headers = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJpbml0aWF0b3IiOiJhdWN0aW9uIn0.BxbygFbyg2WOjV-lzmjvrYiFWBHPnw252InbPLkztaQ'
      allow_any_instance_of(ApplicationController).to receive(:auth_header).and_return(request.headers)

      expect(instance.logged_in?).to be_truthy
    end

    it 'should authorized if initiator eeid exist' do
      stub_const('ENV', { 'billing_secret' => 'secret' })
      instance = ApplicationController.new
      request = OpenStruct.new
      request.headers = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJpbml0aWF0b3IiOiJlZWlkIn0.H6Y_dAhd9b667xWnu5Lcs6d9OnWSietky6qzmB7qZh0'
      allow_any_instance_of(ApplicationController).to receive(:auth_header).and_return(request.headers)

      expect(instance.logged_in?).to be_truthy
    end

    it 'should not authorized if initiator not exist' do
      stub_const('ENV', { 'billing_secret' => 'secret' })
      instance = ApplicationController.new
      request = OpenStruct.new
      request.headers = 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJpbml0aWF0b3IiOiJyZWdpcyJ9.--ZswSprxo76vuJv7BaFio5VGGojaOnrD6V66cTtevY'
      allow_any_instance_of(ApplicationController).to receive(:auth_header).and_return(request.headers)

      expect(instance.logged_in?).to be_falsey
    end
  end
end
