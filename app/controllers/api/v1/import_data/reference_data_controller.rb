class Api::V1::ImportData::ReferenceDataController < ApplicationController
  def create
    response = params["_json"]

    response.each do |data|
      reference_number = data["reference_number"]
      initiator = data["initiator"]

      next unless Reference.find_by(reference_number: reference_number, initiator: initiator).nil?

      logger.info ">>>>>>>>>>"
      logger.info data
      logger.info reference_number
      logger.info ">>>>>>>>>>"

      log_request(reference_number: reference_number, initiator: initiator)

      Reference.create!(reference_number: reference_number, initiator: initiator)
    end

    render status: 200, json: { status: 'ok' }
  end

  def log_request(reference_number:, initiator:)
    logger.info reference_number
    logger.info initiator
    logger.info "++++++++++++++++++"
  end
end
