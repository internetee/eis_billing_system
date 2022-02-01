require 'rails_helper'

RSpec.describe 'DirectoInvoiceForwardJob', type: :job do
  it_behaves_like 'should send invoices to directo'
end
