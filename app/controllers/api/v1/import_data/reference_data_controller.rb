class Api::V1::ImportData::ReferenceDataController < ApplicationController
  def create
    data = SaveReferenceDataJob.perform_now(params["_json"])

    render status: 200,
           json: { message: "Added #{data[0]} reference numbers, skipped #{data[1]}. The reason for omission may be that the reference data is already in the database or the information is incorrect" }
  end
end
