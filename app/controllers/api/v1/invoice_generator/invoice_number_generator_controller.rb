class Api::V1::InvoiceGenerator::InvoiceNumberGeneratorController < Api::V1::InvoiceGenerator::BaseController
  api! 'Returns the closest free invoice number in the range. No parameters required'

  def create
    invoice_number = InvoiceNumberService.call

    if invoice_number == 'out of range'
      return render json: { 'message' => "Number create failed. #{invoice_number}",
                            'error' => invoice_number }, status: :not_implemented
    end

    render json: { 'message' => "Number created; #{invoice_number}",
                   'invoice_number' => invoice_number },
           status: :created
  end
end
