RSpec.shared_examples 'everypay link generator' do
  let(:invoice) { create(:invoice) }

  it 'it should generate link for specific invoice' do
    expect_any_instance_of(EverypayV4Wrapper::LinkBuilder).to receive(:build_link).and_return('http://everypay.link')

    EverypayLinkGenerator.create(invoice: invoice)

    expect(invoice.payment_link).to match('http://everypay.link')
  end
end
