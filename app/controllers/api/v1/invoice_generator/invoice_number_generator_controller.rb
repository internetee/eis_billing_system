class Api::V1::InvoiceGenerator::InvoiceNumberGeneratorController < Api::V1::InvoiceGenerator::BaseController
  INVOICE_NUMBER_MIN = Setting.invoice_number_min || 150005
  INVOICE_NUMBER_MAX = Setting.invoice_number_max || 199999

  def create
    invoice_number = invoice_number_generate

    return render json: { 'message' => 'Number create failed', 'error' => invoice_number, status: :not_implemented } if invoice_number == 'out of range'

    render json: { 'message' => 'Number created', 'invoice_number' => invoice_number, status: :created }
  end

  private

  def invoice_number_generate
    last_no = Invoice.all.where(invoice_number: INVOICE_NUMBER_MIN...INVOICE_NUMBER_MAX).order(invoice_number: :desc).limit(1).pick(:invoice_number)

    if last_no && last_no >= INVOICE_NUMBER_MIN
      number = last_no.to_i + 1
    else
      number = INVOICE_NUMBER_MIN
    end

    return number if number <= INVOICE_NUMBER_MAX

    'out of range'
  end
end
