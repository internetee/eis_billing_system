RSpec.shared_examples 'send billing mail' do
  let(:invoice) { create(:invoice) }

  # before(:each) do
  #   stub_const('ENV', {'action_mailer_default_protocol' => 'https'})
  #   stub_const('ENV', {'action_mailer_default_host' => 'registry.test'})
  #   stub_const('ENV', {'action_mailer_default_port' => '80'})
  #   stub_const('ENV', {'action_mailer_default_from' => 'no-reply@example.com'})
  #   stub_const('ENV', {'smtp_address' => '172.17.0.1'})
  #   stub_const('ENV', {'smtp_port' => '1025'})
  # end

  # it 'it should send mail for invoice owner' do
  #   expect_any_instance_of(EverypayV4Wrapper::LinkBuilder).to receive(:build_link).and_return('http://everypay.link')

  #   mail = BillingMailer.invoice_email(invoice: invoice).deliver_now
  #   expect(mail.to).to eq(["clien@mail.ee"])
  #   expect(mail.subject).to eq('Invoice generated')
  # end
end
