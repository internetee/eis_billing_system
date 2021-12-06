class Api::V1::InvoiceGenerator::InvoiceGeneratorController < Api::V1::InvoiceGenerator::BaseController

  # POST
  def create
    return render json: {'message' => 'Parameters missing', status: :error} unless compare_params(params)

    InvoiceGenerator.generate_pdf(params)

    render json: {'message' => 'PDF File created', status: :created}
  rescue StandardError => e
    p e
  end

  # SHOW
  def show
    invoice_number = params[:id]
    send_file "tmp/#{invoice_number}.pdf", { filename: "#{invoice_number}.pdf",
                                             type: "application/pdf",
                                             disposition: "attachment" }
  end

  private

  def compare_params(params)
    params_template.all? { |k, v| params.key?(k.to_sym)}
  end

  def params_template
    {
      sum:  '',
      name: '',
      description: '',
      invoice_number: ''
    }
  end

  def invoice_params
    params.require(:invoice).permit(:invoice_number, :first_name, :last_name, :sum, :description)
  end
end
