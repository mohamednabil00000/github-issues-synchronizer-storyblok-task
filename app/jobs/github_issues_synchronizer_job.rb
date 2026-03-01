# frozen_string_literal: true

class GithubIssuesSynchronizerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    last_issue_id = $redis.get("last_issue_id")
    offset_reached = false
    page = 1
    first_issue_id = nil
    next_cursor = nil

    while !offset_reached
      http_result = Github::RailsRepo::Client.get_issues(page:, cursor: next_cursor)
      return unless http_result.success?

      parsed_data_result = GithubRepoData::ParsingService.call(data: http_result.payload[:body], offset: last_issue_id)
      return unless parsed_data_result.success?

      break if parsed_data_result.payload[:issues].empty?

      if first_issue_id.nil?
        first_issue_id = parsed_data_result.payload[:issues][0][:id]
      end

      offset_reached = parsed_data_result.payload[:offset_reached]

      persisted_data_result = GithubRepoData::PersistingService.call(
        users_data: parsed_data_result.payload[:users],
        issues_data: parsed_data_result.payload[:issues]
      )
      return unless persisted_data_result.success?

      break if http_result.payload[:after_cursor].nil?

      next_cursor = "after=#{http_result.payload[:after_cursor]}"
      page += 1
    end
    $redis.set("last_issue_id", first_issue_id) if first_issue_id.present?
  end
end
