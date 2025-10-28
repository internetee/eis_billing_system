require 'rails_helper'

RSpec.describe HttpBuildQuery do
  describe '.create' do
    it 'encodes simple hash with spaces as +' do
      q = described_class.create({ 'a' => 'hello world' })
      expect(q).to eq('a=hello+world')
    end

    it 'percent-encodes special characters' do
      q = described_class.create({ 'email' => 'a+b@example.com' })
      expect(q).to include('email=a%2Bb%40example.com')
    end

    it 'supports nested hash and arrays' do
      q = described_class.create({ 'user' => { 'name' => 'John', 'tags' => ['a', 'b'] } })
      # order is sorted by keys
      expect(q).to include('user%5Bname%5D=John')
      expect(q).to include('user%5Btags%5D%5B0%5D=a')
      expect(q).to include('user%5Btags%5D%5B1%5D=b')
    end

    it 'raises on unsupported type' do
      expect { described_class.create(Object.new) }.to raise_error(ArgumentError)
    end
  end
end


