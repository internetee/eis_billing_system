require 'rails_helper'

RSpec.describe "Api::V1::CallbackHandler::CallbackHandlers", type: :request do
  it_behaves_like 'should update payment status'
  it_behaves_like 'should notify initiator'
end
