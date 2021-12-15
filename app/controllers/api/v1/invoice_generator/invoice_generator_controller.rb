class Api::V1::InvoiceGenerator::InvoiceGeneratorController < Api::V1::InvoiceGenerator::BaseController
  def create
    return render json: { 'message' => 'Parameters missing', status: :error } unless compare_params(params)

    # Temporary solution
    params[:order_reference] = 5.times.map { rand(10) }.join
    params[:reference_number] = 5.times.map { rand(10) }.join

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

  def params_template
    {
      # reference_number: '',
      # order_reference: '',
      sum:  '',
      email: '',
      code: '',
      role: '',
      name: '',
      description: '',
      invoice_number: ''
    }
  end

  def invoice_params
    params.require(:invoice).permit(:invoice_number, :name, :sum, :description, :email, :code, :role)
  end
end
