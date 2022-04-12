class SaveReferenceDataJob < ApplicationJob
  def perform(response)
    response.each do |data|
      reference_number = data["reference_number"]
      initiator = data["initiator"]

      next unless Reference.find_by(reference_number: reference_number, initiator: initiator).nil?

      log_request(reference_number: reference_number, initiator: initiator)

      Reference.create!(reference_number: reference_number, initiator: initiator)
    end
  end

  def log_request(reference_number:, initiator:)
    Rails.logger.info reference_number
    Rails.logger.info initiator
    Rails.logger.info "++++++++++++++++++"
  end
end