module Auction
  class DepositPrepaymentService
    include BaseService

    DESCRIPTION_DEFAULT = 'deposit'.freeze

    attr_reader :params

    def initialize(params:)
      @params = params
    end

    def self.call(params:)
      new(params: params).call
    end

    def call
      contract = DepositPrepaymentContract.new
      result = contract.call(params)

      result.success? ? oneoff_link : parse_validation_errors(result)
    end
  end
end
