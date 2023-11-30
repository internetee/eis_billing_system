class InvoiceCreatorsController < ParentController
  def index
    @pagy, @invoices = pagy(Invoice.search(params).where(initiator: 'billing_system').order(created_at: :desc),
                            items: params[:per_page] ||= 25,
                            link_extra: 'data-turbo-action="advance"')
    @min_amount = 0
    @max_amount = 200_000
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
        transaction_amount: @invoice.transaction_amount
      )

      @linkpay = EverypayLinkGenerator.create(params: linkpay_params_mutation)
      @invoice.linkpay_info = {
        linkpay: @linkpay,
        customer_name: params[:linkpay][:customer_name],
        customer_email: params[:linkpay][:customer_email],
        description: params[:linkpay][:custom_field1],
        custom_field2: params[:linkpay][:custom_field2],
        invoice_number: @invoice.invoice_number
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
