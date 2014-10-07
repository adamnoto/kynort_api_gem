require "kynort_gem/version"
require "active_support/configurable"
require "rest_client"
require "json"

module Kynort
  include ActiveSupport::Configurable

  TITLE_MISTER = "Mr"
  TITLE_MS = "Ms"
  TITLE_MRS = "Mrs"

  class << self
    def setup
      config.app_key = nil
      config.secret_key = nil
      config.host = "http://localhost:4001"
      yield config
    end
  end

  module_function

  def token
    if @token.nil? || (Time.now.to_i + 200) > @token_expired_time
      response = RestClient.post "#{config.host}/oauth/token", {
        grant_type: "client_credentials",
        client_id: config.app_key,
        client_secret: config.secret_key
      }
      response = JSON.parse(response)

      @token = response["access_token"]
      @token_expired_time = Time.now.to_i + Integer(response["expires_in"])
    end
    @token
  end

  def new_request
    reply = RestClient.get "#{config.host}/api/api_request/new.json", params: {access_token: token}
    ApiRequest.new(reply)
  end

  def explain_request(guid)
    reply = RestClient.get "#{config.host}/api/api_request/explain.json", params: {access_token: token, request_guid: guid}
    ApiRequest.new(reply)
  end
end

require "kynort_gem/flights"
require "kynort_gem/normalize_country"
require "kynort_gem/api_request"