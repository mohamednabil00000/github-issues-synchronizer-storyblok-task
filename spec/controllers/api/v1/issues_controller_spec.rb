# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V1::IssuesController, type: :controller do
  describe "GET #index" do
    let(:user) { create(:user) }
    let!(:open_issue) { create(:issue, state: "open", user:) }
    let!(:closed_issue) { create(:issue, state: "closed", user:) }

    before { get :index, params: }

    context "without filters" do
      let(:params) { {} }

      it "returns all issues" do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["issues"].size).to eq(2)
      end
    end

    context "with state filter" do
      let(:params) { { state: "open" } }

      it "returns only open issues" do
        expect(response).to have_http_status(:ok)
        issues = JSON.parse(response.body)["issues"]
        expect(issues.size).to eq(1)
        expect(issues.first["state"]).to eq("open")
      end
    end
  end
end
