class Api::V1::ImportData::ReferenceDataController < ApplicationController
  def create
    SaveReferenceDataJob.perform_now(params["_json"])

    render status: 200, json: { status: 'ok' }
  end
end
