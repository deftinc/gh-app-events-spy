require 'elasticsearch'

class GithubWebhooksController < ApplicationController
  def handle
    client.index(index: 'github_events', body: payload)
  end

  private

  def payload
    {
      event: request.headers["X-GitHub-Event"],
      action: request.body["action"],
      headers: request.headers,
      payload: request.body,
    }
  end

  def client
    @client ||= Elasticsearch::Client.new(host: ENV.fetch('BONSAI_URL'), log: true)
  end
end
