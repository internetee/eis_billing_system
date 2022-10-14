module Auction
  class BulkPaymentService
    include BaseService

    attr_reader :params

    def initialize(params:)
      @params = params
    end

    def self.call(params:)
      new(params: params).call
    end

    def call
      contract = BulkPaymentContract.new
      result = contract.call(params)

      result.success? ? oneoff_link : parse_validation_errors(result)
    end
  end
end
