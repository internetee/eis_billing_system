RSpec.shared_examples "Token generator" do
  let(:token) { generate_key }

  it 'encoded token' do
    expect(base_key.decrypt_and_verify(token)).to eq GlobalVariable::INVOICE_SECRET_WORD
  end

  def generate_key
    base_key.encrypt_and_sign(GlobalVariable::INVOICE_SECRET_WORD)
  end

  def base_key
    ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31], Rails.application.secrets.secret_key_base)
  end
end
