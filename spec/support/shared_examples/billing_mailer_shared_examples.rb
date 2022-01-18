RSpec.shared_examples 'send billing mail' do
  let(:invoice) { create(:invoice) }

  it 'it should send mail for invoice owner' do
    mail = BillingMailer.invoice_email(invoice: invoice).deliver_now
    expect(mail.to).to eq([invoice.buyer_email])
    expect(mail.subject).to eq('Invoice generated')
  end
end
