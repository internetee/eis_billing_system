module Api
  module V1
    module Directo
      class DirectoController < ApplicationController
        api! 'Send existing invoices to Directo accounting service'

        param :invoice_data, Array, of: Hash, desc: <<~HERE
          Contains information about invoices in directo format, which is put in the scheme and sent by request to directo
        HERE
        param :dry, [true, false]
        param :monthly, [true, false], desc: 'A switch that allows you to send payments for the month'
        param :initiator, String, desc: <<~HERE
          Values contains the names of the service that initiates the request. These can be:
          - registry
          - eeid
          - auction
        HERE

        def create
          invoice_data = params[:invoice_data]
          dry = params[:dry]
          monthly = params[:monthly]
          initiator = params[:initiator]

          DirectoInvoiceForwardJob.perform_now(invoice_data: invoice_data,
                                               initiator: initiator,
                                               monthly: monthly,
                                               dry: dry)

          render json: { 'message' => 'Invoice data received' }, status: :created
        end
      end
    end
  end
end
