module GenerateInvoiceInstance
  extend self

  def process(params)
    @params = params

    @user_params = {
      name: @params[:buyer_name],
      reference_number: @params[:reference_number],
      email: @params[:buyer_email],
      code: @params[:buyer_reg_no], # maybe need to add buyer_code???
      role: @params[:role]
    }

    @everypay_params = {
      status: 0,

      description: @params[:description],
      currency: @params[:currency],
      invoice_number: @params[:invoice_number],
      transaction_amount: translate_money(@params[:transaction_amount]),
      seller_name: @params[:seller_name],
      seller_reg_no: @params[:seller_reg_no],
      seller_iban: @params[:seller_iban],
      seller_bank: @params[:seller_bank],
      seller_swift: @params[:seller_swift],
      seller_vat_no: @params[:seller_vat_no],
      seller_country_code: @params[:seller_country_code],
      seller_state: @params[:seller_state],
      seller_street: @params[:seller_street],
      seller_city: @params[:seller_city],
      seller_zip: @params[:seller_zip],
      seller_phone: @params[:seller_phone],
      seller_url: @params[:seller_url],
      seller_email: @params[:seller_email],
      seller_contact_name: @params[:seller_contact_name],
      buyer_name: @params[:buyer_name],
      buyer_reg_no: @params[:buyer_reg_no],
      buyer_country_code: @params[:buyer_country_code],
      buyer_state: @params[:buyer_state],
      buyer_street: @params[:buyer_street],
      buyer_city: @params[:buyer_city],
      buyer_zip: @params[:buyer_zip],
      buyer_phone: @params[:buyer_phone],
      buyer_url: @params[:buyer_url],
      buyer_email: @params[:buyer_email],
      vat_rate: @params[:vat_rate],
      reference_number: @params[:reference_number]
    }

    generate_invoice
  end

  private

  def find_or_create_user
    user = User.find_by(reference_number: @user_params[:reference_number])

    return user unless user.nil?

    User.create!(@user_params)
  end

  def generate_invoice
    @everypay_params[:user_id] = find_or_create_user.id

    Invoice.create!(@everypay_params)
  end

  def translate_money(sum)
    money = Money.new(sum, 'EUR')
    money&.format(symbol: nil, thousands_separator: false, decimal_mark: '.')
  end
end
