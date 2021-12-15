module GenerateInvoiceInstance
  extend self

  def process(params)
    @params = params

    @user_params = {
      name: @params[:name],
      reference_number: @params[:reference_number],
      email: @params[:email],
      code: @params[:code],
      role: @params[:role]
    }

    @everypay_params = {
      invoice_number: @params[:invoice_number],
      description: @params[:description],
      transaction_amount: translate_money(@params[:sum]),
      customer_name: @params[:name],
      customer_email: @params[:email],
      order_reference: @params[:order_reference],
      reference_number: @params[:reference_number],
      status: 0
    }

    generate_invoice
  end

  private

  def find_or_create_user
    user = User.find_by(reference_number: @user_params[:reference_number])

    return user unless user.nil?

    User.create(@user_params)
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
