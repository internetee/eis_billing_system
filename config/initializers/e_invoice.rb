# e_invoice_provider_name: 'omniva'
# e_invoice_provider_password:
# e_invoice_provider_test_mode: 'false'

provider_config = { password: ENV['e_invoice_provider_password'] || '',
                    # test_mode: ENV['e_invoice_provider_test_mode'] == 'true' }
                    test_mode: false }
EInvoice.provider = EInvoice::Providers::OmnivaProvider.new(provider_config)
