RSpec.shared_examples 'invoice instance generator' do |params|
  let(:user) { create(:user) }

  it 'it should generate new user instance' do
    user.reference_number = '2233'
    user.save

    params[:reference_number] = '2234'

    expect{GenerateInvoiceInstance.process(params)}.to change{User.count}.by(1)
  end

  it 'it should not generate new user instance if reference numbers are match' do
    user.reference_number = '2233'
    user.save

    params[:reference_number] = '2233'

    expect{GenerateInvoiceInstance.process(params)}.to change{User.count}.by(0)
  end

  it 'should generate new invoice' do
    expect{GenerateInvoiceInstance.process(params)}.to change{Invoice.count}.by(1)
  end
end
