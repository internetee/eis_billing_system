# rubocop:disable Metrics
class WhiteCodesController < ParentController
  before_action :set_white_code, only: %i[edit update destroy]

  def index
    @white_codes = WhiteCode.all
    @new_white_code = WhiteCode.new
  end

  def new
    @white_code = WhiteCode.new
  end

  def edit; end

  def create
    @white_code = WhiteCode.new(strong_params)

    respond_to do |format|
      if @white_code.save
        flash.now[:notice] = 'Identity code added to white list'
        @white_code_new = WhiteCode.new

        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash,
            turbo_stream.append('white_codes', partial: 'white_codes/white_code', locals: { white_code: @white_code }),
            turbo_stream.replace('admin_form', partial: 'white_codes/form', locals: { white_code: @white_code_new, url: white_codes_path })
          ]
        end
      else
        format.turbo_stream do
          flash.now[:alert] = @white_code.errors.full_messages.join(', ')
          render turbo_stream: [render_turbo_flash]
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @white_code.update(strong_params)
        flash.now[:notice] = 'Identity code in white list was updated'
        @white_code_new = WhiteCode.new

        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash,
            turbo_stream.replace(@white_code, partial: 'white_codes/white_code', locals: { white_code: @white_code }),
            turbo_stream.replace('admin_form', partial: 'white_codes/form', locals: { white_code: @white_code_new, url: white_codes_path })
          ]
        end
      else
        format.turbo_stream do
          flash.now[:alert] = @white_code.errors.full_messages.join(', ')
          render turbo_stream: [render_turbo_flash]
        end
      end
    end
  end

  def destroy
    code = @white_code.code
    respond_to do |format|
      if @white_code.destroy
        flash.now[:alert] = "#{code} was deleted from white list"
        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash,
            turbo_stream.remove(@white_code)
          ]
        end
      else
        format.turbo_stream do
          flash.now[:alert] = @white_code.errors.full_messages.join(', ')
          render turbo_stream: [
            render_turbo_flash
          ]
        end
      end
    end
  end

  private

  def strong_params
    params.require(:white_code).permit(:code)
  end

  def set_white_code
    @white_code = WhiteCode.find(params[:id])
  end
end
