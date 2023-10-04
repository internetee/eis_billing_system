class EInvoiceGenerator
  attr_reader :invoice, :payable, :items, :buyer_billing_email,
              :buyer_e_invoice_iban, :invoice_subtotal, :invoice_balance_date,
              :invoice_balance_begin, :invoice_inbound, :invoice_outbound,
              :invoice_balance_end, :invoice_vat_amount,
              :seller_country_code, :buyer_country_code, :e_invoice_data

  def initialize(e_invoice_data)
    @invoice = e_invoice_data[:invoice_data]
    @payable = e_invoice_data[:payable]
    @invoice_subtotal = e_invoice_data[:invoice_subtotal]
    @invoice_vat_amount = e_invoice_data[:vat_amount]
    @invoice_balance_date = e_invoice_data[:balance_date]
    @invoice_balance_begin = e_invoice_data[:balance_begin]
    @invoice_inbound = e_invoice_data[:inbound]
    @invoice_outbound = e_invoice_data[:outbound]
    @invoice_balance_end = e_invoice_data[:balance_end]
    @items = e_invoice_data[:invoice_items]
    @buyer_billing_email = e_invoice_data[:buyer_billing_email]
    @buyer_e_invoice_iban = e_invoice_data[:buyer_e_invoice_iban]
    @seller_country_code = e_invoice_data[:seller_country_code]
    @buyer_country_code = e_invoice_data[:buyer_country_code]
  end

  def generate
    seller = EInvoice::Seller.new
    seller.name = invoice[:seller_name]
    seller.registration_number = invoice[:seller_reg_no]
    seller.vat_number = invoice[:seller_vat_no]

    seller_legal_address = EInvoice::Address.new
    seller_legal_address.line1 = invoice[:seller_street]
    seller_legal_address.line2 = invoice[:seller_state]
    seller_legal_address.postal_code = invoice[:seller_zip]
    seller_legal_address.city = invoice[:seller_city]
    seller_legal_address.country = Country.new(seller_country_code)
    seller.legal_address = seller_legal_address

    buyer = EInvoice::Buyer.new
    buyer.name = invoice[:buyer_name]
    buyer.registration_number = invoice[:buyer_reg_no]
    buyer.vat_number = invoice[:buyer_vat_no]
    buyer.email = buyer_billing_email

    buyer_bank_account = EInvoice::BankAccount.new
    buyer_bank_account.number = buyer_e_invoice_iban
    buyer.bank_account = buyer_bank_account

    buyer_legal_address = EInvoice::Address.new
    buyer_legal_address.line1 = invoice[:buyer_street]
    buyer_legal_address.line2 = invoice[:buyer_state]
    buyer_legal_address.postal_code = invoice[:buyer_zip]
    buyer_legal_address.city = invoice[:buyer_city]
    buyer_legal_address.country = Country.new(buyer_country_code)
    buyer.legal_address = buyer_legal_address

    e_invoice_invoice_items = []
    items.each do |invoice_item|
      e_invoice_invoice_item = generate_invoice_item(invoice, invoice_item)
      e_invoice_invoice_items << e_invoice_invoice_item
    end

    e_invoice_name_item = e_invoice_invoice_items.shift if invoice[:monthly_invoice]

    e_invoice_invoice = EInvoice::Invoice.new.tap do |i|
      i.seller = seller
      i.buyer = buyer
      i.name = e_invoice_name_item&.description
      i.items = e_invoice_invoice_items
      i.number = invoice[:number]
      i.date = invoice[:issue_date]
      i.recipient_id_code = invoice[:buyer_reg_no]
      i.reference_number = invoice[:reference_no]
      i.due_date = invoice[:due_date]
      i.beneficiary_name = invoice[:seller_name]
      i.beneficiary_account_number = invoice[:seller_iban]
      i.payer_name = invoice[:buyer_name]
      i.subtotal = invoice_subtotal
      i.vat_amount = invoice_vat_amount
      i.total = invoice[:total]
      i.total_to_pay = invoice[:total_to_pay]
      i.currency = invoice[:currency]
      i.delivery_channel = %i[internet_bank portal]
      i.payable = payable
      i.monthly_invoice = invoice[:monthly_invoice]
      i.balance_date = invoice_balance_date
      i.balance_begin = invoice_balance_begin
      i.inbound = invoice_inbound
      i.outbound = invoice_outbound
      i.balance_end = invoice_balance_end
    end

    EInvoice::EInvoice.new(date: Time.zone.today, invoice: e_invoice_invoice)
  end

  def generate_invoice_item(invoice, invoice_item)
    EInvoice::InvoiceItem.new.tap do |i|
      i.description = invoice_item[:description]
      i.price = invoice_item[:price]
      i.quantity = invoice_item[:quantity]
      i.unit = invoice_item[:unit]
      if invoice[:monthly_invoice] && invoice_item[:price] && invoice_item[:quantity]
        i.vat_rate = invoice[:vat_rate].to_f
        i.subtotal = (invoice_item[:price].to_f * invoice_item[:quantity].to_f).round(2)
        i.vat_amount = (i.subtotal * (i.vat_rate / 100)).round(2)
        i.total = (i.subtotal + i.vat_amount).round(2)
      else
        i.subtotal = invoice_item[:subtotal]
        i.vat_rate = invoice_item[:vat_rate]
        i.vat_amount = invoice_item[:vat_amount]
        i.total = invoice_item[:total]
      end
    end
  end
end
