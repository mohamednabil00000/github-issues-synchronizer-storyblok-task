# frozen_string_literal: true

class GithubIssuesSynchronizerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    current_offset = $redis.get("last_issue_id")&.to_i
    offset_reached = false
    page = 1
    new_offset = nil
    next_cursor = nil

    while !offset_reached
      http_result = Github::RailsRepo::Client.get_issues(page:, cursor: next_cursor)
      return unless http_result.success?

      parsed_data_result = GithubRepoData::ParsingService.call(data: http_result.payload[:body], offset: current_offset)
      return unless parsed_data_result.success?

      new_offset = parsed_data_result.payload[:recent_issue_id] if new_offset.nil?
      offset_reached = parsed_data_result.payload[:offset_reached]

      return unless persist_github_data?(parsed_data_result.payload)

      break if http_result.payload[:after_cursor].nil?

      next_cursor = "after=#{http_result.payload[:after_cursor]}"
      page += 1
    end
    $redis.set("last_issue_id", new_offset) if new_offset.present?
  end

  private
    def persist_github_data?(payload)
      GithubRepoData::PersistingService.call(
        users_data: payload[:users],
        issues_data: payload[:issues]
      ).success?
    end
end
