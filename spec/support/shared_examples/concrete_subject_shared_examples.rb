RSpec.shared_examples 'should notify all callback observers' do
  it_behaves_like 'should update payment status'
  it_behaves_like 'should notify initiator'
end