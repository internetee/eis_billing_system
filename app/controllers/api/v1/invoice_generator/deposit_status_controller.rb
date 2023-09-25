module Api
  module V1
    module InvoiceGenerator
      class DepositStatusController < Api::V1::InvoiceGenerator::BaseController
        before_action :set_invoice, only: :create
        before_action :set_status, only: :create

        api! 'Invoice deposit status updates'

        param :invoice_number, String, required: true
        param :status, String, required: true

        def create
          if @invoice.update(status: @status)
            render json: { 'message' => 'Status updated' }, status: :ok
          else
            error_message = "Status for #{params[:invoice_number]} wasn't updated; Status #{@status}"
            NotifierMailer.inform_admin('Status received error', error_message).deliver_now
            render json: { 'error' => error_message }, status: :unprocessable_entity
          end
        rescue StandardError => e
          Rails.logger.info e
          NotifierMailer.inform_admin('Status received standard error', e).deliver_now
        end

        private

        # rubocop:disable Metrics/AbcSize
        def set_invoice
          @invoice = ::Invoice.where("description LIKE ? AND description LIKE ?", "%#{params[:domain_name]}%", "%#{params[:user_uuid]}%").first
          return if @invoice.present? && @invoice.affiliation == 'auction_deposit'

          message = "Invoice with #{params[:domain_name]} and #{params[:user_uuid]} not found in Deposit Status Controller"
          NotifierMailer.inform_admin("Invoice with #{params[:domain_name]} and #{params[:user_uuid]} not found", message).deliver_now

          render json: { 'error' => message }, status: :unprocessable_entity and return
        end

        def set_status
          @status = reform_status[params[:status]]
          return if %w[paid unpaid refunded].include?(@status)

          message = "Wrong invoice status #{@status} in Deposit Status Controller"
          NotifierMailer.inform_admin("Invoice status #{@status} is wrong", message).deliver_now

          render json: { 'error' => message }, status: :unprocessable_entity and return
        end

        def reform_status
          {
            'paid' => 'paid',
            'prepayment' => 'unpaid',
            'returned' => 'refunded'
          }
        end
      end
    end
  end
end
