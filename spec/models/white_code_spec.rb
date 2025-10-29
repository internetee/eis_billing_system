require 'rails_helper'

RSpec.describe WhiteCode, type: :model do
  describe 'validations' do
    it 'validates code presence' do
      white_code = WhiteCode.new
      expect(white_code).not_to be_valid
      expect(white_code.errors[:code]).to include("can't be blank")
    end

    it 'validates code length between 10-12 characters' do
      white_code = WhiteCode.new(code: '123456789')
      expect(white_code).not_to be_valid
      expect(white_code.errors[:code]).to include('is too short (minimum is 10 characters)')

      white_code.code = '1234567890123'
      expect(white_code).not_to be_valid
      expect(white_code.errors[:code]).to include('is too long (maximum is 12 characters)')

      white_code.code = '1234567890'
      expect(white_code).to be_valid
    end
  end
end