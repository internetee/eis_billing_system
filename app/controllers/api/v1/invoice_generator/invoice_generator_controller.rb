class Api::V1::InvoiceGenerator::InvoiceGeneratorController < Api::V1::InvoiceGenerator::BaseController
  def create
    return render json: { 'message' => 'Parameters missing', status: :error } unless compare_params(params)

    GenerateInvoiceInstance.process(params)
    InvoiceGenerator.generate_pdf(params[:reference_number])

    render json: { 'message' => 'PDF File created', status: :created }
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

  def compare_params(params)
    params_template.all? { |k, v| params.key?(k.to_sym) }
  end

  # "id"=>81, "currency"=>"EUR", "description"=>"", "reference_no"=>"2199812", "vat_rate"=>"20.0", "seller_name"=>"Eesti Interneti SA", "seller_reg_no"=>"90010019", "seller_iban"=>"EE557700771000598731", "seller_bank"=>"LHV Pank", "seller_swift"=>"LHVBEE22", "seller_vat_no"=>"EE101286464", "seller_country_code"=>"EE", "seller_state"=>"Harjumaa", "seller_street"=>"Paldiski mnt 80", "seller_city"=>"Tallinn", "seller_zip"=>"10617", "seller_phone"=>"+372 727 1000", "seller_url"=>"www.internet.ee", "seller_email"=>"info@internet.ee", "seller_contact_name"=>"Martti Õigus", "buyer_id"=>2, "buyer_name"=>"New", "buyer_reg_no"=>"12345611", "buyer_country_code"=>"EE", "buyer_state"=>"Hatjumaa", "buyer_street"=>"Kivila 13", "buyer_city"=>"Tallinn", "buyer_zip"=>"13919", "buyer_phone"=>"372.35345345", "buyer_url"=>"https://eis.ee", "buyer_email"=>"hello@eestiinternet.ee", "creator_str"=>"3-ApiUser: oleghasjanov", "updator_str"=>"3-ApiUser: oleghasjanov", "number"=>131098, "cancelled_at"=>nil, "in_directo"=>false, "buyer_vat_no"=>"123456789", "role"=>"registrar", "invoice_number"=>"2232", "transaction_amount"=>"924.0", "invoice_generator"=>{"id"=>81, "currency"=>"EUR", "description"=>"", "reference_no"=>"2199812", "vat_rate"=>"20.0", "seller_name"=>"Eesti Interneti SA", "seller_reg_no"=>"90010019", "seller_iban"=>"EE557700771000598731", "seller_bank"=>"LHV Pank", "seller_swift"=>"LHVBEE22", "seller_vat_no"=>"EE101286464", "seller_country_code"=>"EE", "seller_state"=>"Harjumaa", "seller_street"=>"Paldiski mnt 80", "seller_city"=>"Tallinn", "seller_zip"=>"10617", "seller_phone"=>"+372 727 1000", "seller_url"=>"www.internet.ee", "seller_email"=>"info@internet.ee", "seller_contact_name"=>"Martti Õigus", "buyer_id"=>2, "buyer_name"=>"New", "buyer_reg_no"=>"12345611", "buyer_country_code"=>"EE", "buyer_state"=>"Hatjumaa", "buyer_street"=>"Kivila 13", "buyer_city"=>"Tallinn", "buyer_zip"=>"13919", "buyer_phone"=>"372.35345345", "buyer_url"=>"https://eis.ee", "buyer_email"=>"hello@eestiinternet.ee", "creator_str"=>"3-ApiUser: oleghasjanov", "updator_str"=>"3-ApiUser: oleghasjanov", "number"=>131098, "cancelled_at"=>nil, "in_directo"=>false, "buyer_vat_no"=>"123456789", "role"=>"registrar", "invoice_number"=>"2232", "transaction_amount"=>"924.0"}

  def params_template
    {
      reference_number: '',

      description: '',
      currency: '',
      invoice_number: '',
      transaction_amount: '',
      seller_name: '',
      seller_reg_no: '',
      seller_iban: '',
      seller_bank: '',
      seller_swift: '',
      seller_vat_no: '',
      seller_country_code: '',
      seller_state: '',
      seller_street: '',
      seller_city: '',
      seller_zip: '',
      seller_phone: '',
      seller_url: '',
      seller_email: '',
      seller_contact_name: '',
      buyer_name: '',
      buyer_reg_no: '',
      buyer_country_code: '',
      buyer_state: '',
      buyer_street: '',
      buyer_city: '',
      buyer_zip: '',
      buyer_phone: '',
      buyer_url: '',
      buyer_email: '',
      vat_rate: '',
      role: '',
      buyer_vat_no: '',
      # buyer_iban: '',
      # invoice_items: [],
    }
  end

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
