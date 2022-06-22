module Api
  module V1
    module ImportData
      class InvoiceDataController < ApplicationController
        def create
          data = SaveInvoiceDataJob.perform_now(params['_json'])
          message = "Added #{data[0]} invoices, skipped #{data[1]}." \
                    ' The reason for omission may be that the account data is' \
                    'already in the database or the information is incorrect'

          render status: :ok, json: { message: message }
        end
      end
    end
  end
end
