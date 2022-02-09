class Api::V1::CallbackHandler::BaseController < ApplicationController
  skip_before_action :authorized 
end
