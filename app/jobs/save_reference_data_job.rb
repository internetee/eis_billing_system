class SaveReferenceDataJob < ApplicationJob
  def perform(response)
    response.each do |data|
      reference_number = data["reference_number"]
      initiator = data["initiator"]
      registrar_name = data["registrar_name"]

      next unless Reference.find_by(reference_number: reference_number, initiator: initiator, owner: registrar_name).nil?

      log_request(reference_number: reference_number, initiator: initiator, owner: registrar_name)

      Reference.create!(reference_number: reference_number, initiator: initiator, owner: registrar_name)
    end
  end

  def log_request(reference_number:, initiator:,  owner:)
    Rails.logger.info reference_number
    Rails.logger.info initiator
    Rails.logger.info owner

    Rails.logger.info "++++++++++++++++++"
  end
end