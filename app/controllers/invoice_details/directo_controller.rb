class InvoiceDetails::DirectoController < ParentController
  require 'rexml/document'
  def show
    directo = Invoice.find(params[:id])

    if directo.directo_data.present?
      doc = REXML::Document.new directo.directo_data
      out = ''
      doc.write(out, 1)

      @directo = out
    else
      @directo = 'No data from directo'
    end
  end
end
