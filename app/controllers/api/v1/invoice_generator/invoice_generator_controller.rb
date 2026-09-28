module Api
  module V1
    module InvoiceGenerator
      class InvoiceGeneratorController < ApplicationController
        AUCTION = 'auction'.freeze
        EVERYPAY_PROVIDER = 'everypay'.freeze

        api! <<~HERE
          Payment link generator for an invoice.

          The response always contains **everypay_link** (EveryPay LinkPay, exactly as before).
          For auction invoices that carry a **due_date** the payment link is created in Montonio
          instead, because only Montonio can expire the link at the invoice due date. In that case
          **payment_link** points to Montonio and **payment_link_provider** is `montonio`.
          If Montonio is not configured or fails, **payment_link** falls back to the EveryPay link
          (which has no expiry) and **payment_link_provider** is `everypay`.

          Response 201:

              {
                "message": "Link created",
                "everypay_link": "https://igw-demo.every-pay.com/lp?...",
                "payment_link": "https://pay.montonio.com/<uuid>",
                "payment_link_provider": "montonio",
                "payment_link_expires_at": "2026-07-09T20:59:59Z"
              }

          **payment_link_expires_at** is null when the link has no expiry.
        HERE

        param :transaction_amount, String, required: true, desc: <<~HERE
          The total amount to be paid
        HERE
        param :reference_number, String, required: false
        param :order_reference, String, required: true, desc: <<~HERE
          This is the description of the account. As a rule, the account number is indicated here
        HERE
        param :customer_name, String, required: true
        param :customer_email, String, required: true
        param :custom_field_1, String, required: true, desc: <<~HERE
          Invoice description
        HERE
        param :custom_field2, String, required: true, desc: <<~HERE
          Values contains the names of the service that initiates the request. These can be:
          - registry
          - eeid
          - auction
          - business_registry

          In this case, only the auction has the possibility of multiple payment
        HERE
        param :linkpay_token, String, required: true, desc: <<~HERE
          Token to be generated based on everypay client api and everypay client key
        HERE
        param :invoice_number, String, required: true
        param :due_date, String, required: false, desc: <<~HERE
          Invoice due date in `YYYY-MM-DD` format. The payment link stops accepting payments at the
          end of that day in Estonian time (Europe/Tallinn). Currently used by the auction only.
          An unparsable value is answered with 422.
        HERE
        param :return_url, String, required: false, desc: <<~HERE
          Where the payer is redirected after paying in Montonio
        HERE
        param :locale, String, required: false, desc: <<~HERE
          Language of the Montonio payment page: de, en, et, fi, lt, lv, pl or ru. Defaults to `en`
        HERE

        def create
          expiry = LinkpayExpiry.new(params[:due_date])
          invoice = InvoiceInstanceGenerator.create(params:)
          everypay_link = EverypayLinkGenerator.create(params:)
          payment_link = build_payment_link(invoice:, everypay_link:, expiry:)

          render json: { 'message' => 'Link created',
                         'everypay_link' => everypay_link,
                         'payment_link' => payment_link[:url],
                         'payment_link_provider' => payment_link[:provider],
                         'payment_link_expires_at' => payment_link[:expires_at] },
                 status: :created
        rescue LinkpayExpiry::InvalidDueDate => e
          render json: { 'message' => e.message }, status: :unprocessable_entity
        rescue StandardError => e
          Rails.logger.info e
        end

        private

        def build_payment_link(invoice:, everypay_link:, expiry:)
          return everypay_fallback(everypay_link) unless montonio_link?(expiry)

          link = create_montonio_link(invoice, expiry)
          persist_montonio_link(invoice, link)

          { url: link.url, provider: Montonio::PROVIDER, expires_at: expiry.iso8601 }
        rescue StandardError => e
          # Losing the expiry is bad, but not being able to pay at all is worse,
          # so we fall back to the EveryPay link and shout about it.
          Rails.logger.error("Montonio payment link failed for invoice #{invoice.invoice_number}, " \
                             "falling back to an EveryPay link without expiry: #{e.class}: #{e.message}")
          invoice.update(payment_link: everypay_link, payment_link_provider: EVERYPAY_PROVIDER)

          everypay_fallback(everypay_link)
        end

        def everypay_fallback(everypay_link)
          { url: everypay_link, provider: EVERYPAY_PROVIDER, expires_at: nil }
        end

        def montonio_link?(expiry)
          params[:custom_field2].to_s == AUCTION && expiry.present? && Montonio.configured?
        end

        def create_montonio_link(invoice, expiry)
          Montonio::PaymentLinkGenerator.call(invoice_number: invoice.invoice_number,
                                              amount: invoice.transaction_amount,
                                              description: invoice.description,
                                              expires_at: expiry.iso8601,
                                              locale: params[:locale],
                                              return_url: params[:return_url])
        end

        def persist_montonio_link(invoice, link)
          invoice.with_lock do
            invoice.update!(payment_link: link.url,
                            payment_link_uuid: link.uuid,
                            payment_link_provider: Montonio::PROVIDER,
                            linkpay_info: (invoice.linkpay_info || {}).merge(montonio_info(invoice, link)))
          end
        rescue StandardError => e
          # The link exists in Montonio but we could not store it - log the uuid
          # so the orphaned link can be found by hand.
          Rails.logger.error("Could not store Montonio payment link #{link.uuid} (#{link.url}) for invoice " \
                             "#{invoice.invoice_number}: #{e.class}: #{e.message}")
          raise
        end

        def montonio_info(invoice, link)
          {
            'montonio' => {
              'uuid' => link.uuid,
              'url' => link.url,
              'short_url' => link.short_url,
              'expires_at' => link.expires_at,
              'due_date' => invoice.due_date&.to_s,
              'return_url' => params[:return_url].presence,
              'created_at' => Time.zone.now.iso8601
            }
          }
        end
      end
    end
  end
end
