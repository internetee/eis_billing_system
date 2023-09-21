class InvoiceDetails::EverypayResponseController < ParentController
  def show
    everypay = Invoice.find(params[:id])
    @everypay = everypay.everypay_response
    @everypay = 'No data from everypay' if @everypay.nil?
  end
end
