class Api::V1::InvoiceGenerator::ReferenceNumberGeneratorController < ApplicationController
  def create
    initiator = params['initiator']
    reference_number = nil
    loop do
      reference_number = generate

      reference = Reference.find_by(reference_number: reference_number)
      if reference.nil?
        Reference.create!(reference_number: reference_number, initiator: initiator)

        break
      end
    end

    render json: { 'message' => "Reference number created; #{reference_number}", 'reference_number' => reference_number }, status: :created
  end

  private

  def generate
    Billing::ReferenceNo.generate
  end
end
