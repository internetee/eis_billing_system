RSpec.shared_examples 'Invoice generator' do |params|
  it 'should generate pdf template' do
    allow_any_instance_of(PDFKit).to receive(:to_file).and_return true

    expect(InvoiceGenerator.generate_pdf(params)).to be true
  end
end
