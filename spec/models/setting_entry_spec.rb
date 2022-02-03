require 'rails_helper'

RSpec.describe SettingEntry, type: :model do
  let(:setting_entry) { create(:setting_entry) }

  describe 'validation settings test' do
    it 'setting code is required' do
      expect(setting_entry.valid?).to be true
      setting_entry.code = 'a b'
      expect(setting_entry.valid?).to be false
    end

    it 'setting code can only include underscore and characters' do
      expect(setting_entry.valid?).to be true
      setting_entry.code = 'a b'
      expect(setting_entry.valid?).to be false

      setting_entry.code = 'ab_'
      expect(setting_entry.valid?).to be false

      setting_entry.code = '_ab'
      expect(setting_entry.valid?).to be false

      setting_entry.code = '1_2'
      expect(setting_entry.valid?).to be false

      setting_entry.code = 'a_b'
      expect(setting_entry.valid?).to be true
    end

    it 'setting value can be nil' do
      expect(setting_entry.valid?).to be true
      setting_entry.value = nil
      expect(setting_entry.valid?).to be true
    end

    it 'setting format is required' do
      expect(setting_entry.valid?).to be true
      setting_entry.format = nil
      expect(setting_entry.valid?).to be false

      setting_entry.format = 'nonexistant'
      expect(setting_entry.valid?).to be false
    end

    it 'setting group is required' do
      expect(setting_entry.valid?).to be true
      setting_entry.group = nil
      expect(setting_entry.valid?).to be false

      setting_entry.group = 'random'
      expect(setting_entry.valid?).to be true
    end

    it 'returns nil for unknown setting' do
      expect(Setting.unknown_and_definitely_not_saved_setting).to be nil
    end
  end

  describe "parsing setting type of values tests" do
    it "parses string format" do
      Setting.create(code: 'string_format', value: '1', format: 'string', group: 'random')
      expect(Setting.string_format.is_a? String).to be true
    end

    it "parses integer format" do
      Setting.create(code: 'integer_format', value: '1', format: 'integer', group: 'random')
      expect(Setting.integer_format.is_a? Integer).to be true
    end

    it "parses float format" do
      Setting.create(code: 'float_format', value: '0.5', format: 'float', group: 'random')
      expect(Setting.float_format.is_a? Float).to be true
    end

    it "parses boolean format" do
      Setting.create(code: 'boolean_format', value: 'true', format: 'boolean', group: 'random')
      expect(Setting.boolean_format).to be true

      Setting.boolean_format = 'false'
      expect(Setting.boolean_format).to be false

      Setting.boolean_format = nil
      expect(Setting.boolean_format).to be false
    end

    it "parses hash format" do
      Setting.create(code: 'hash_format', value: '{"hello": "there"}', format: 'hash', group: 'random')
      expect(Setting.hash_format.is_a? Hash).to be true
    end

    it "parses array format" do
      Setting.create(code: 'array_format', value: '[1, 2, 3]', format: 'array', group: 'random')
      expect(Setting.array_format.is_a? Array).to be true
    end
  end
end
