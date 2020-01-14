require 'elasticsearch'

class GithubWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action -> { head :unauthorized unless Rack::Utils.secure_compare(signature, expected_signature) }

  def handle
    client.index(index: 'github_events', body: payload)
    render plain: 'Thanks, GitHub!'
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

  def signature
    @signature ||= request.headers['X-Hub-Signature']
  end

  def expected_signature
    @expected_signature ||= "sha1=#{OpenSSL::HMAC.hexdigest('sha1', ENV['GITHUB_WEBHOOK_SECRET'], request.raw_post)}"
  end
end
