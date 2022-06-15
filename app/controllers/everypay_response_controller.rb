class EverypayResponseController < ParentController
  before_action :require_user_logged_in!

  def show
    everypay = Invoice.find(params[:id])
    @everypay = everypay.everypay_response
    @everypay = "No data from everypay" if @everypay.nil?
  end
end
