class SaveReferenceDataJob < ApplicationJob
  def perform(response)
    added_count = 0
    skipped_count = 0

    response.each do |data|
      reference_number = data["reference_number"]
      initiator = data["initiator"]
      registrar_name = data["registrar_name"]

      unless Reference.find_by(reference_number: reference_number, initiator: initiator, owner: registrar_name).nil?
        skipped_count += 1

        next
      end

      log_request(reference_number: reference_number, initiator: initiator, owner: registrar_name)

      Reference.create!(reference_number: reference_number, initiator: initiator, owner: registrar_name)

      added_count += 1
    end

    [added_count, skipped_count]
  end

  def log_request(reference_number:, initiator:,  owner:)
    Rails.logger.info reference_number
    Rails.logger.info initiator
    Rails.logger.info owner

    Rails.logger.info "++++++++++++++++++"
  end
end