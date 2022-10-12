require 'rails_helper'

RSpec.describe Reference, type: :model do
  describe '#valid' do
    it 'should create a new reference' do
      expect do
        described_class.create(
          reference_number: '12345',
          initiator: 'registry',
          owner: 'Roga & Kopyta'
        )
      end.to change { described_class.count }
    end
  end

  describe '#unit' do
    let(:reference) { create(:reference) }

    context 'search' do
      it 'should find record by reference number' do
        result = described_class.search(reference_number: reference.reference_number)
        expect(result.count).to eq 1
      end
    end
  end
end
