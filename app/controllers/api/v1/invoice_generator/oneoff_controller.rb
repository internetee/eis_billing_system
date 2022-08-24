class Api::V1::InvoiceGenerator::OneoffController < Api::V1::InvoiceGenerator::BaseController
  def create
    response = Oneoff.send_request(invoice_number: params[:invoice_number], customer_url: params[:customer_url])
    parsed_response = JSON.parse(response)

    if parsed_response['error'].presence
      render json: { error: parsed_response['error'] }, status: :unprocessable_entity
    end

    render json: { 'message' => 'Link created',
                   'oneoff_redirect_link' => parsed_response['payment_link'] },
           status: :created
  rescue StandardError => e
    Rails.logger.info e
  end
end
