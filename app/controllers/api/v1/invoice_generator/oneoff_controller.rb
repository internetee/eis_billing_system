class Api::V1::InvoiceGenerator::OneoffController < Api::V1::InvoiceGenerator::BaseController
  def create
    response = Oneoff.send_request(invoice_number: params[:invoice_number],
                                   customer_url: params[:customer_url],
                                   reference_number: params[:reference_number])
    # parsed_response = JSON.parse(response)

    if response['error'].presence
      render json: { error: response['error'] }, status: :unprocessable_entity
    end

    render json: { 'message' => 'Link created',
                   'oneoff_redirect_link' => response['payment_link'] },
           status: :created
  rescue StandardError => e
    Rails.logger.info e
  end
end
