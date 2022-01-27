class Api::V1::InvoiceGenerator::InvoiceGeneratorController < Api::V1::InvoiceGenerator::BaseController
  def create
    link = InvoiceGenerator.run(params)

    render json: { 'message' => 'Link created', 'everypay_link' => link, status: :created }
  rescue StandardError => e
    p e
  end

  def show
    invoice_number = params[:id]
    send_file "tmp/#{invoice_number}.pdf", { filename: "#{invoice_number}.pdf",
                                             type: 'application/pdf',
                                             disposition: 'attachment' }
  end

  private

  def invoice_params
    params.require(:invoice).permit(
      :description,
      :currency,
      :invoice_number,
      :transaction_amount,
      :order_reference,
      :seller_name,
      :seller_reg_no,
      :seller_iban,
      :seller_bank,
      :seller_swift,
      :seller_vat_no,
      :seller_country_code,
      :seller_state,
      :seller_street,
      :seller_city,
      :seller_zip,
      :seller_phone,
      :seller_url,
      :seller_email,
      :seller_contact_name,
      :buyer_name,
      :buyer_reg_no,
      :buyer_country_code,
      :buyer_state,
      :buyer_street,
      :buyer_city,
      :buyer_zip,
      :buyer_phone,
      :buyer_url,
      :buyer_email,
      :vat_rate,
      :items_attributes,
      :role,
      :buyer_iban,
      :buyer_vat_no,
      :reference_number,
      :invoice_items
    )
  end
end
