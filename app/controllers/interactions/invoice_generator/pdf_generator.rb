module PdfGenerator
  extend self

  def generate(invoice:)
    @everypay_params = {
      transaction_amount: invoice.transaction_amount,
      order_reference: invoice.invoice_number,
      customer_name: invoice.buyer_name,
      customer_email: invoice.buyer_email,
      custom_field_1: invoice.description,
      invoice_number: invoice.invoice_number,
      linkpay_token: GlobalVariable::LINKPAY_TOKEN
    }

    generate_it
  end

  private

  def generate_link
    linker = EverypayV4Wrapper::LinkBuilder.new(key: GlobalVariable::KEY, params: @everypay_params)
    linker.build_link
  end

  def generate_it
    pdf_template.to_file(filename)
  end

  def pdf_template
    PDFKit.new(
      <<-HTML
      <h1>#{@everypay_params[:invoice_number]}</h1>
      <h2>#{@everypay_params[:customer_name]}</h2>
      <p>Your sum is #{@everypay_params[:transaction_amount]}</p>
      <p>Your description is #{@everypay_params[:custom_field_1]}</p>
      <p>You can pay <a href="#{generate_link}">here</a></p>
    HTML
    )
  end

  def filename
    "#{@everypay_params[:invoice_number]}.pdf"
  end
end
