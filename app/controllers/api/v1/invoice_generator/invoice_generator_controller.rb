module Api
  module V1
    module InvoiceGenerator
      class InvoiceGeneratorController < ApplicationController
        # skip_before_action :authorized

        def create
          InvoiceInstanceGenerator.create(params: params)
          link = EverypayLinkGenerator.create(params: params)

          render json: { 'message' => 'Link created', 'everypay_link' => link }, status: :created
        rescue StandardError => e
          Rails.logger.info e
        end
      end
    end
  end
end
