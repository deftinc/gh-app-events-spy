require 'elasticsearch'

class GithubWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action -> { head :unauthorized unless Rack::Utils.secure_compare(signature, expected_signature) }

  def handle
    render json: client.index(index: 'github_events', body: payload)
  end

  private

  def payload
    {
      event: request_headers["HTTP_X_GITHUB_EVENT"],
      action: request_json["action"],
      headers: request_headers,
      payload: request_json,
      timestamp: Time.now.utc.iso8601,
    }
  end

  def request_json
    @request_json ||= JSON.parse(request.headers["RAW_POST_DATA"])
  end

  def request_headers
    @request_headers ||= Hash[request.headers.select{|key, value| key =~ /[A-Z]+.*/ && key != "RAW_POST_DATA" }]
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
