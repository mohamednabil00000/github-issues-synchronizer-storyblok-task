# frozen_string_literal: true

class Api::BaseController < ActionController::API
  include Pagy::Method
end
