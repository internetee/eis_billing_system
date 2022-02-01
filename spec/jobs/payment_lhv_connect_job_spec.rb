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

  describe "notify about status of transactions" do
    it "should notify if user not exists" do
      # instance = spy('PaymentLhvConnectJob')
      # PaymentLhvConnectJob.perform_now(test: true)

      # expect(instance).to have_receive(:make_some_action_if_user_is_nil)
    end
  end
end
