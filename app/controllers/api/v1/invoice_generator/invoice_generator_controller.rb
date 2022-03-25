class Api::V1::InvoiceGenerator::InvoiceGeneratorController < Api::V1::InvoiceGenerator::BaseController
  def create
    link = InvoiceGenerator.run(params)

    render json: { 'message' => 'Link created', 'everypay_link' => link, status: :created }
  rescue StandardError => e
    logger.info e
  end
end
