module GenerateInvoiceInstance
  extend self

  def process(params)
    @params = params

    p "++++++"
    p @params[:source]

    #<Invoice id: 7, result_id: 7, user_id: 3, billing_profile_id: 2, issue_date: "2022-01-21", due_date: "2022-01-28", created_at: "2022-01-21 17:02:57.572749000 +0200", updated_at: "2022-01-21 17:02:57.572749000 +0200", cents: 6000, paid_at: nil, status: "issued", number: 7, uuid: "891d924c-c8db-43c9-a862-e9b65647a5ca", vat_rate: nil, paid_amount: nil, updated_by: nil, notes: nil, paid_with_payment_order_id: nil, recipient: "Oleg Hasjanov", vat_code: "1234 5678 9012", legal_entity: nil, street: "Pelguranna", city: "Tallinn", state: nil, postal_code: "13919", alpha_two_country_code: "EE", in_directo: false>
    #<User id: 3, email: "oleg@test.ee", created_at: "2022-01-21 12:39:15.096052000 +0200", updated_at: "2022-01-21 12:50:05.357780000 +0200", alpha_two_country_code: "EE", identity_code: nil, given_names: "Oleg", surname: "Hasjanoc", mobile_phone: "+37259813319", roles: ["participant"], terms_and_conditions_accepted_at: "2022-01-21 12:39:15.087303000 +0200", uuid: "ab425191-1e2c-4114-a09d-ca596adef244", mobile_phone_confirmed_at: "2022-01-21 12:45:30.871222000 +0200", mobile_phone_confirmation_code: "9111", locale: "en", provider: nil, uid: nil, updated_by: nil, daily_summary: true, discarded_at: nil>
    # #<BillingProfile id: 2, user_id: 3, name: "Oleg Hasjanov", vat_code: "1234 5678 9012", street: "Pelguranna", city: "Tallinn", state: nil, postal_code: "13919", created_at: "2022-01-21 13:21:15.950542000 +0200", updated_at: "2022-01-21 13:21:15.950542000 +0200", alpha_two_country_code: "EE", uuid: "78f520e4-ada4-477b-b60e-1fb0262ff451", updated_by: nil>

    if @params[:source] == 'auction'
      invoice = parse_auction_params
    elsif @params[:source] == 'registry'
      invoice = parse_registrar_params
    else
      p "++++++"
      p @params
      p "++++++"

      invoice = nil
    end

    invoice
  end

  private

  #Transaction amount
  # Invoice number
  # Customer name
  # Customer email
  # Description
  # Order reference

  def parse_auction_params
    @everypay_params = {
      transaction_amount: @params[:cents],
      invoice_number: @params[:number],
      customer_name: @params[:customer_name],
      customer_email: @params[:customer_email],
      description: @params[:description],
      order_reference: @params[:order_reference]
    }

    nil
  end

  def parse_registrar_params
    @user_params = {
      name: @params[:buyer_name],
      reference_number: @params[:reference_number],
      email: @params[:buyer_email],
      code: @params[:buyer_reg_no], # maybe need to add buyer_code???
      role: @params[:role]
    }

    @everypay_params = {
      status: 0,

      description: @params[:description], #
      currency: @params[:currency], #
      invoice_number: @params[:number], #
      # transaction_amount: translate_money(@params[:transaction_amount]),
      transaction_amount: @params[:transaction_amount],
      # ================
      seller_name: @params[:seller_name], #
      seller_reg_no: @params[:seller_reg_no], #
      seller_iban: @params[:seller_iban], #
      seller_bank: @params[:seller_bank], #
      seller_swift: @params[:seller_swift], #
      seller_vat_no: @params[:seller_vat_no], #
      seller_country_code: @params[:seller_country_code],  #
      seller_state: @params[:seller_state], #
      seller_street: @params[:seller_street], #
      seller_city: @params[:seller_city], #
      seller_zip: @params[:seller_zip], #
      seller_phone: @params[:seller_phone], #
      seller_url: @params[:seller_url], #
      seller_email: @params[:seller_email], #
      seller_contact_name: @params[:seller_contact_name], #
      # =================
      buyer_name: @params[:buyer_name], #
      buyer_reg_no: @params[:buyer_reg_no], #
      buyer_country_code: @params[:buyer_country_code], #
      buyer_state: @params[:buyer_state], #
      buyer_street: @params[:buyer_street], #
      buyer_city: @params[:buyer_city], #
      buyer_zip: @params[:buyer_zip], #
      buyer_phone: @params[:buyer_phone], #
      buyer_url: @params[:buyer_url], #
      buyer_email: @params[:buyer_email], #
      vat_rate: @params[:vat_rate], #
      reference_number: @params[:reference_number], #
      issue_date: @params[:issue_date], #
      due_date: @params[:due_date], #
      invoice_items: @params[:items] #
    }

    generate_invoice
  end

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
