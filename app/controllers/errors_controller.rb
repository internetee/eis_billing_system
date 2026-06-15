class ErrorsController < ParentController
  allow_unauthenticated

  def show
    @exception = request.env['action_dispatch.exception']
    @status_code = @exception.try(:status_code) ||
                   ActionDispatch::ExceptionWrapper.new(
                     request.env, @exception
                   ).status_code

    log_exception

    respond_to do |format|
      format.html { render view_for_code(@status_code), status: @status_code }
      format.json { render json: error_payload, status: @status_code }
      format.any  { render json: error_payload, status: @status_code, content_type: 'application/json' }
    end
  end

  private

  def log_exception
    return if @exception.nil?

    wrapped = @exception.cause || @exception

    Rails.logger.error(
      "[ErrorsController] #{@status_code} on #{request.method} " \
      "#{request.original_fullpath} (format=#{request.format.try(:ref).inspect}) " \
      "request_id=#{request.request_id} -> " \
      "#{wrapped.class}: #{wrapped.message}"
    )
    Rails.logger.error(wrapped.backtrace.join("\n")) if wrapped.backtrace
  end

  def error_payload
    {
      error: Rack::Utils::HTTP_STATUS_CODES.fetch(@status_code, 'Error'),
      status: @status_code
    }
  end

  def view_for_code(code)
    supported_error_codes.fetch(code, '404')
  end

  def supported_error_codes
    {
      401 => '401',
      403 => '403',
      404 => '404',
      500 => '500'
    }
  end
end
