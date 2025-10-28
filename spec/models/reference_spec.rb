require 'rails_helper'

RSpec.describe Reference, type: :model do
  describe 'searching class method' do
    let(:reference) { create(:reference, reference_number: 'REF-123', initiator: 'registry') }

    it 'finds reference by number' do
      params = { reference_number: 'REF-123' }
      expect(Reference.search(params)).to include(reference)
    end

    it 'sorts by specified column and direction' do
      create(:reference, reference_number: 'REF-001')
      create(:reference, reference_number: 'REF-002')

      params = { sort: 'reference_number', direction: 'asc' }
      results = Reference.search(params)
      expect(results.first.reference_number).to eq('REF-001')
    end

    it 'uses default sort when invalid params provided' do
      params = { sort: 'invalid', direction: 'invalid' }
      expect(Reference.search(params)).to be_a(ActiveRecord::Relation)
    end
  end

  describe 'scopes' do
    it 'filters by reference number' do
      ref1 = create(:reference, reference_number: 'REF-123')
      ref2 = create(:reference, reference_number: 'REF-456')

      results = Reference.with_number('REF-123')
      expect(results).to include(ref1)
      expect(results).not_to include(ref2)
    end
  end
end