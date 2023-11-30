class InvoiceCreatorsController < ParentController
  def index
    @invoices = Invoice.where(initiator: 'billing_system').order(created_at: :desc)
  end

  def new
    invoice_number = InvoiceNumberService.call
    @invoice = Invoice.new(
      invoice_number:,
      affiliation: :linkpay,
      initiator: 'billing_system'
    )
  end

  def create
    @invoice = Invoice.new
    @invoice.invoice_number = params[:invoice][:invoice_number]
    @invoice.affiliation = params[:invoice][:affiliation]
    @invoice.initiator = params[:invoice][:initiator]
    @invoice.transaction_amount = params[:invoice][:transaction_amount]
    @invoice.description = params[:invoice][:description]

    ActiveRecord::Base.transaction do
      @invoice.save!

      linkpay_params_mutation = params[:linkpay].merge(
        invoice_number: @invoice.invoice_number,
        transaction_amount: @invoice.transaction_amount,
      )

      @linkpay = EverypayLinkGenerator.create(params: linkpay_params_mutation)
      @invoice.everypay_response = {
        linkpay: @linkpay,
      }

      @invoice.save!
    end

    redirect_to invoice_creators_path, notice: 'Invoice was successfully created.', status: :see_other
  rescue ActiveRecord::RecordInvalid => e
    flash.now[:error] = e.message
    render :new and return
  end

  def show; end
end
