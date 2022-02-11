RSpec.shared_examples 'invoice generator' do |params|
  it_behaves_like 'generate invoice instance'
  it_behaves_like 'everypay link generator'

  describe "run interaction with params" do
    before { allow_any_instance_of(ApplicationController).to receive(:authorized).and_return(true) }

    it "should generate invoice instance" do
      expect_any_instance_of(EverypayV4Wrapper::LinkBuilder).to receive(:build_link).and_return('http://everypay.link')

      expect { InvoiceGenerator.run(params) }.to change { Invoice.count }.by(1)
    end

    it "should generate invoice link" do
      expect_any_instance_of(EverypayV4Wrapper::LinkBuilder).to receive(:build_link).and_return('http://everypay.link')

      link = InvoiceGenerator.run(params)
      expect(link).to eq('http://everypay.link')
    end
  end
end
