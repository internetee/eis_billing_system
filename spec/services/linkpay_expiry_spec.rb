require 'rails_helper'

RSpec.describe LinkpayExpiry do
  describe '#iso8601' do
    it 'expires at the end of the due date in Estonian summer time (UTC+3)' do
      expect(described_class.new('2026-07-09').iso8601).to eq('2026-07-09T20:59:59Z')
    end

    it 'expires at the end of the due date in Estonian winter time (UTC+2)' do
      expect(described_class.new('2026-12-09').iso8601).to eq('2026-12-09T21:59:59Z')
    end

    it 'accepts a Date object' do
      expect(described_class.new(Date.new(2026, 7, 9)).iso8601).to eq('2026-07-09T20:59:59Z')
    end

    it 'has no expiry without a due date' do
      expect(described_class.new(nil).iso8601).to be_nil
      expect(described_class.new('').iso8601).to be_nil
      expect(described_class.new('   ').iso8601).to be_nil
    end
  end

  describe '#end_of_day' do
    it 'is the last second of the due date in Tallinn' do
      expect(described_class.new('2026-07-09').end_of_day.strftime('%Y-%m-%d %H:%M:%S %z'))
        .to eq('2026-07-09 23:59:59 +0300')
    end
  end

  describe '#present?' do
    it 'tells whether there is a due date' do
      expect(described_class.new('2026-07-09')).to be_present
      expect(described_class.new(nil)).not_to be_present
    end
  end

  describe '.parse_date' do
    it 'parses a strict YYYY-MM-DD string' do
      expect(described_class.parse_date('2026-07-09')).to eq(Date.new(2026, 7, 9))
    end

    it 'returns nil for blank values' do
      expect(described_class.parse_date(nil)).to be_nil
      expect(described_class.parse_date('')).to be_nil
    end

    it 'raises on a differently formatted date instead of dropping the expiry' do
      expect { described_class.parse_date('09.07.2026') }.to raise_error(described_class::InvalidDueDate)
      expect { described_class.parse_date('2026-7-9') }.to raise_error(described_class::InvalidDueDate)
      expect { described_class.parse_date('tomorrow') }.to raise_error(described_class::InvalidDueDate)
    end

    it 'raises on an impossible date' do
      expect { described_class.parse_date('2026-02-31') }.to raise_error(described_class::InvalidDueDate)
    end
  end
end
