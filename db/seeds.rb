# BankStatement.create(
#     bank_code: '689',
#     iban: 'EE557700771000598731'
# )

ActiveRecord::Base.transaction do
  # Create dynamic Setting objects
  SettingEntry.create(code: 'directo_sales_agent', value: 'HELEN', format: 'string', group: 'billing')
  SettingEntry.create(code: 'default_language', value: 'en', format: 'string', group: 'other')
  SettingEntry.create(code: 'invoice_number_min', value: '150005', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'invoice_number_max', value: '199999', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'days_to_keep_invoices_active', value: '30', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'days_to_keep_overdue_invoices_active', value: '0', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'directo_receipt_payment_term', value: 'R', format: 'string', group: 'billing')
  SettingEntry.create(code: 'directo_receipt_product_name', value: 'ETTEM06', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_billing_email', value: 'info@internet.ee', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_invoice_contact', value: 'Martti Õigus', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_vat_no', value: 'EE101286464', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_bank', value: 'LHV Pank', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_iban', value: 'EE557700771000598731', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_swift', value: 'LHVBEE22', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_email', value: 'info@internet.ee', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_phone', value: '+372 727 1000', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_url', value: 'www.internet.ee', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_street', value: 'Paldiski mnt 80', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_city', value: 'Tallinn', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_state', value: 'Harjumaa', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_country_code', value: 'EE', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'directo_monthly_number_min', value: '309901', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'directo_monthly_number_max', value: '309999', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'registry_bank_code', value: '689', format: 'string', group: 'billing')
  SettingEntry.create(code: 'registry_reg_no', value: '90010019', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_zip', value: '10617', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'registry_juridical_name', value: 'Eesti Interneti SA', format: 'string', group: 'contacts')
  SettingEntry.create(code: 'directo_monthly_number_last', value: '309901', format: 'integer', group: 'billing')
  SettingEntry.create(code: 'registry_bank_account_iban_lhv', value: 'EE177700771001155322', format: 'string', group: 'billing')
  SettingEntry.create(code: 'invoice_number_auction_deposit_min', value: ENV['deposit_min_num'].to_i, format: 'integer', group: 'billing')
  SettingEntry.create(code: 'invoice_number_auction_deposit_max', value: ENV['deposit_max_num'].to_i, format: 'integer', group: 'billing')
end
