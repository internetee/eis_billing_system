require 'rails_helper'

RSpec.describe WhiteCode, type: :model do
  it 'should validate length of code' do
    w = WhiteCode.new(code: '123456789')
    expect(w.valid?).to be false

    w.code = '1234567890123'
    expect(w.valid?).to be false

    w.code = '1234567890'
    expect(w.valid?).to be true
  end
end
