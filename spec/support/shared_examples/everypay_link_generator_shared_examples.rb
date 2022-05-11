def params(reference_number: '12233', buyer_name: 'Oleg')
  {
    reference_number: reference_number,

    description:  'this is description',
    currency: 'EUR',
    invoice_number: '12332',
    transaction_amount: '1000',
    seller_name: 'EIS',
    seller_reg_no: '122',
    seller_iban: '34234234234424',
    seller_bank: 'LHV',
    seller_swift: '1123344',
    seller_vat_no: '23321',
    seller_country_code: 'EE',
    seller_state: 'Harjumaa',
    seller_street: 'Paldiski mnt',
    seller_city: 'Tallinn',
    seller_zip: '223323',
    seller_phone: '+372.342342',
    seller_url: 'eis.ee',
    seller_email: 'eis@internet.ee',
    seller_contact_name: 'Eesti Internet SA',
    buyer_name: buyer_name,
    buyer_reg_no: '324344',
    buyer_country_code: 'EE',
    buyer_state: 'Harjumaa',
    buyer_street: 'Kivila',
    buyer_city: 'Tallinn',
    buyer_zip: '13919',
    buyer_phone: '+372.59813318',
    buyer_url: 'n-brains.com',
    buyer_email: 'oleg.hasjanov@eestiinternet.ee',
    vat_rate: '20',
    role: 'private_user',
    buyer_vat_no: '23323',
    buyer_iban: '4454322423432',
    invoice_items: [{
                      description: 'some_some',
                      price: '1233',
                      quantity: '2',
                      unit: '3',
                      subtotal: '5',
                      vat_rate: '10',
                      vat_amount: '23',
                      total: '44'
                    },
                    {
                      description: 'some_some_some',
                      price: '12',
                      quantity: '1',
                      unit: '2',
                      subtotal: '3',
                      vat_rate: '5',
                      vat_amount: '10',
                      total: '22'
                    },
    ]
  }
end

RSpec.shared_examples 'everypay link generator' do
  let(:invoice) { create(:invoice) }

  it 'it should generate link for specific invoice' do
    allow_any_instance_of(EverypayLinkGenerator).to receive(:build_link).and_return('http://everypay.link')

    link = EverypayLinkGenerator.create(params: params)

    expect(link).to match('http://everypay.link')
  end
end
