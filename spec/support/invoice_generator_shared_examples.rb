RSpec.shared_examples 'Invoice generator' do |reference_number|
  let(:user) { create(:user) }
  let(:invoice) { create(:invoice, reference_number: reference_number) }

  it 'should generate pdf template' do
    params = {
      transaction_amount:  '1234',
      customer_name: 'oleg hasjanov',
      custom_field_1: 'this_is_description',
      invoice_number: '12221',
      reference_number: invoice.reference_number
    }

    allow_any_instance_of(PDFKit).to receive(:to_file).and_return true

    expect(InvoiceGenerator.generate_pdf(params[:reference_number])).to be true
  end
end
