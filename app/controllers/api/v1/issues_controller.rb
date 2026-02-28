# frozen_string_literal: true

class Api::V1::IssuesController < Api::BaseController
  # GET /api/v1/issues
  def index
    issues = Issue.includes(:user)
    result = Issues::ApplyFiltersService.call(issues:, filter_params:)
    if result.success?
      render json: { issues: IssueSerializer.collection(result.payload) }, status: :ok
    else
      render json: { errors: result.error }, status: :bad_request
    end
  end

  private
    def filter_params
      params.permit(:state)
    end
end
