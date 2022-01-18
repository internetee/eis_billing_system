require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "EInvoice" do
    let (:invoice) { build(:invoice) }

    it "should generate inner seller instance in EInvoice Struct" do
      invoice.seller_name = 'Test name'
      invoice.seller_reg_no = '12223'
      invoice.save
      e_invoice = invoice.to_e_invoice

      expect(e_invoice.invoice.seller.class.name).to match('EInvoice::Seller')
      expect(e_invoice.invoice.seller.name).to match('Test name')
      expect(e_invoice.invoice.seller.registration_number).to match('12223')
    end

    it "should generate inner buyer instance in EInvoice Struct" do
      invoice.buyer_name = 'Test name'
      invoice.buyer_reg_no = '12223'
      invoice.save
      e_invoice = invoice.to_e_invoice

      expect(e_invoice.invoice.buyer.class.name).to match('EInvoice::Buyer')
      expect(e_invoice.invoice.buyer.name).to match('Test name')
      expect(e_invoice.invoice.buyer.registration_number).to match('12223')
    end
  end

  describe "Model column properties" do
    let (:invoice) { build(:invoice) }

    it "should be #cancelled if invoice fill out cancelled datetime column" do
      expect(invoice.cancelled?).to be(false)

      invoice.cancelled_at = Time.zone.now
      invoice.save

      expect(invoice.cancelled?).to be(true)
    end

    it "should #not sent e-invoice if invoice was cancelled" do
      expect(invoice.do_not_send_e_invoice?).to be(false)

      invoice.cancelled_at = Time.zone.now
      invoice.save

      expect(invoice.do_not_send_e_invoice?).to be(true)
    end

    it "should be #e_invoice_sent if invoice fill out e_invoice_sent_at datetime column" do
      expect(invoice.e_invoice_sent?).to be(false)

      invoice.e_invoice_sent_at = Time.zone.now
      invoice.save

      expect(invoice.e_invoice_sent?).to be(true)
    end

    it "should #not sent e-invoice if invoice was send before" do
      expect(invoice.do_not_send_e_invoice?).to be(false)

      invoice.e_invoice_sent_at = Time.zone.now
      invoice.save

      expect(invoice.do_not_send_e_invoice?).to be(true)
    end
  end

  describe 'class converter methods' do
    let (:invoice) { build(:invoice) }

    it "should return seller country based on seller country code" do
      invoice.seller_country_code = "EE"
      invoice.save

      expect(invoice.seller_country.name).to match('Estonia')
    end

    it "should return buyer country based on buyer country code" do
      invoice.buyer_country_code = "EE"
      invoice.save

      expect(invoice.buyer_country.name).to match('Estonia')
    end
  end

  describe 'actions with invoice items' do
    let (:invoice) { build(:invoice) }

    before(:each) do

    end

    it 'should calculate sum of one invoice item without vat' do
      expect(invoice.invoice_items[0]["price"]).to eq(123)
      expect(invoice.invoice_items[0]["quantity"]).to eq(2)
      expect(invoice.item_sum_without_vat(item_price: invoice.invoice_items[0]["price"], item_quantity: invoice.invoice_items[0]["quantity"])).to eq(246)
    end

    it 'should count subtotal invoice items' do
      expect(invoice.invoice_items[0]["price"]).to eq(123)
      expect(invoice.invoice_items[0]["quantity"]).to eq(2)

      expect(invoice.invoice_items[1]["price"]).to eq(13)
      expect(invoice.invoice_items[1]["quantity"]).to eq(1)

      expect(invoice.subtotal).to eq(259)
    end

    it 'shoud calculate vat amount if vat equal 20.0%' do
      invoice.vat_rate = 20.0
      invoice.save

      expect(invoice.vat_amount).to eq(51.8)
    end

    it 'shoudl calculate total invoice cost with amount of invoice items' do
      invoice.vat_rate = 20.0
      invoice.save

      expect(invoice.subtotal).to eq(259)
      expect(invoice.vat_amount).to eq(51.8)

      expect(invoice.total).to eq(310.8)
    end
  end
end
