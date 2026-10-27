module Api
  module V1
    module Invoice
      class InvoicePdfsController < ApplicationController
        api! 'Generate invoice as PDF file'

        param :invoice, Hash, required: true, desc: <<~HERE
          Contains the data of the invoice (number, dates, buyer and seller details, totals)
        HERE
        param :items, Array, required: true, desc: <<~HERE
          Invoice details, those items that form the total bill
        HERE
        param :invoice_subtotal, String, required: false, desc: <<~HERE
          Contains information about the subtotal of an invoice
        HERE
        param :vat_amount, String, required: false, desc: 'Tax figure'

        def create
          data = params.to_unsafe_h
          invoice = data[:invoice]

          unless invoice.is_a?(Hash)
            return render json: { message: 'Invoice data is missing' }, status: :unprocessable_entity
          end

          if invoice[:number].blank?
            return render json: { message: 'Invoice number is missing' }, status: :unprocessable_entity
          end

          if data[:items].blank?
            return render json: { message: 'Invoice items are missing' }, status: :unprocessable_entity
          end

          send_data ::InvoicePdfGenerator.new(data).as_pdf,
                    filename: "Invoice-#{invoice[:number]}.pdf",
                    type: 'application/pdf',
                    disposition: 'attachment'
        end
      end
    end
  end
end
