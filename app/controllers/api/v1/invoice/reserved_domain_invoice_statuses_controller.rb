module Api
  module V1
    module Invoice
      class ReservedDomainInvoiceStatusesController < ApplicationController
        def show
          domain_name = params[:domain_name]
          token = params[:token]
          @invoices = ::Invoice.where('description LIKE ?', "%Reserved domain name: #{domain_name}, Token: #{token}%")

          paid_invoices = @invoices.select(&:paid?)

          if paid_invoices.present?
            render json: {
                     message: 'Domain is reserved',
                     invoice_status: 'paid',
                     invoice_number: paid_invoices.first.invoice_number
                   },
                   status: :ok
          else
            render json: { message: 'Domain is not reserved', invoice_status: 'unpaid' }, status: :ok
          end
        end
      end
    end
  end
end
