module Api
  module V1
    module Invoice
      class ReservedDomainCancellationStatusesController < ApplicationController
        def update
          domain_name = params[:domain_name]
          token = params[:token]

          @invoices = ::Invoice.where('description LIKE ?', "%Reserved domain name: #{domain_name}, Token: #{token}%")
          render json: { message: 'No invoices found' }, status: :not_found and return if @invoices.empty?

          @invoices.select(&:cancelled!)

          render json: { message: 'All invoices cancelled' }, status: :ok
        end
      end
    end
  end
end
