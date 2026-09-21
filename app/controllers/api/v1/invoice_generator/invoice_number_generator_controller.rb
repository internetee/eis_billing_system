class Api::V1::InvoiceGenerator::InvoiceNumberGeneratorController < Api::V1::InvoiceGenerator::BaseController
  api! 'Returns the closest free invoice number in the range. No parameters required'

  def create
    invoice_number = InvoiceNumberService.call

    Rails.logger.info(
      "[BILLING-NUMBER] generated=#{invoice_number.inspect} " \
      "min=#{InvoiceNumberService::INVOICE_NUMBER_MIN} max=#{InvoiceNumberService::INVOICE_NUMBER_MAX} " \
      "db_max=#{Invoice.maximum(:invoice_number).inspect} request_id=#{request.request_id}"
    )

    if invoice_number == 'out of range'
      return render json: { 'message' => "Number create failed. #{invoice_number}",
                            'error' => invoice_number }, status: :not_implemented
    end

    render json: { 'message' => "Number created; #{invoice_number}",
                   'invoice_number' => invoice_number },
           status: :created
  end
end
