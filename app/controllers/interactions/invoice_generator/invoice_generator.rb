module InvoiceGenerator
  extend self

  KEY = 'c05fa8dae730cc0cf57fe445861953fa'
  LINKPAY_PREFIX = 'https://igw-demo.every-pay.com/lp'
  LINKPAY_TOKEN = 'k5t5xq'
  LINKPAY_QR = true

  def generate_pdf(params)
    @params = params

    @everypay_params = {
      transaction_amount:  translate_money(@params[:sum]),
      order_reference: 5.times.map { rand(10) }.join, # Temporary solution
      customer_name: @params[:name],
      customer_email: 'oleg.hasjanov@internet.ee',
      custom_field_1: @params[:description],
      linkpay_token: LINKPAY_TOKEN,
      invoice_number: @params[:invoice_number]
    }

    generate_it
  end

  private

  def generate_link
    linker = EverypayV4Wrapper::LinkBuilder.new(key: KEY, params: @everypay_params)
    linker.build_link
  end

  def translate_money(sum)
      money = Money.new(sum, 'EUR')
      money&.format(symbol: nil, thousands_separator: false, decimal_mark: '.')
  end

  def generate_it
    pdf_template.to_file("tmp/#{filename}")
  end

  def pdf_template
    PDFKit.new(
      <<-HTML
      <h1>#{@params[:invoice_number]}</h1>
      <h2>#{@params[:name]}</h2>
      <p>Your sum is #{translate_money(@params[:sum])}</p>
      <p>Your description is #{@params[:description]}</p>
      <p>You can pay <a href="#{generate_link}">here</a></p>
    HTML
    )
  end

  def filename
    "#{@params[:invoice_number]}.pdf"
  end
end
