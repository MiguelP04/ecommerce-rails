class Api::V1::Admin::BaseController < ApiController
  before_action :authenticate_admin!
end
