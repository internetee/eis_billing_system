require 'rails_helper'

RSpec.describe "PaymentLhvConnectJob", type: :job do
  before(:each) do
    ActiveJob::Base.queue_adapter = :test
  end

  let (:invoice) { build(:invoice) }

  describe "#perform later" do
    it "get transactions" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        PaymentLhvConnectJob.perform_later
      }.to have_enqueued_job
    end
  end

  describe "generate instances" do
    it "Should generate BankStatement and BankTransaction instances" do
      expect(BankStatement.all.count).to eq(0)
      expect(BankTransaction.all.count).to eq(0)

      PaymentLhvConnectJob.perform_now(test: true)

      expect(BankStatement.all.count).to eq(1)
      expect(BankTransaction.all.count).to eq(1)
    end
  end

  describe "update or create invoice instance" do
    it "should update invoice status" do
      reference_no = PaymentLhvConnectJob::REFERENCE_NUMBER_TEST_VALUE
      transaction_amount = PaymentLhvConnectJob::TRANSACTION_SUM_TEST_VALUE

      invoice.reference_number = reference_no
      invoice.transaction_amount = transaction_amount
      invoice.save

      expect(invoice.status).to eq nil
      PaymentLhvConnectJob.perform_now(test: true)
      invoice.reload

      expect(invoice.status).to eq "paid"
    end
  end

  describe "notify about status of transactions" do
    it "should notify if user not exists" do
      instance = spy('PaymentLhvConnectJob')
      PaymentLhvConnectJob.perform_now(test: true)

      expect(instance).to have_receive(:make_some_action_if_user_is_nil)
    end
  end
end
