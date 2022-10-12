module Api
  module V1
    module InvoiceGenerator
      class MonthlyInvoiceNumbersGeneratorController < BaseController
        INVOICE_NUMBER_MIN = Setting.directo_monthly_number_min || 309_901
        INVOICE_NUMBER_MAX = Setting.directo_monthly_number_max || 309_999

        def create
          count = params[:count]
          invoice_numbers = []
          if directo_counter_exceedable?(count)
            return render json: { 'message' => 'Directo Counter is out of period!',
                                  'error' => 'out of range' }, status: :not_implemented
          end

          number = [Setting.directo_monthly_number_last.presence.try(:to_i),
                    INVOICE_NUMBER_MIN].compact.max || 0

          count.times do
            number += 1
            invoice_numbers << number
          end

          Setting.directo_monthly_number_last = number

          render json: { 'invoice_numbers' => invoice_numbers }, status: :created
        end

        private

        def directo_counter_exceedable?(invoice_count)
          last_directo = [Setting.directo_monthly_number_last.presence.try(:to_i),
                          INVOICE_NUMBER_MIN].compact.max || 0

          return true if INVOICE_NUMBER_MAX && INVOICE_NUMBER_MAX < (last_directo + invoice_count)

          false
        end
      end
    end
  end
end