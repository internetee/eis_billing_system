module Api
  module V1
    module ImportData
      class ReferenceDataController < ApplicationController
        api! 'Allows you to import user reference numbers'
        formats ['json']
        param :_json, Array, of: String, required: true, desc: <<~HERE
          Contains a list of numbers, names of number owners and service names
        HERE

        def create
          data = SaveReferenceDataJob.perform_now(params['_json'])
          message = "Added #{data[0]} reference numbers, skipped #{data[1]}." \
                 ' The reason for omission may be that the reference data is' \
                 'already in the database or the information is incorrect'

          render status: :ok, json: { message: message }
        end
      end
    end
  end
end
