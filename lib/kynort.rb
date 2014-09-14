require "configuration"
require "kynort_gem/version"
require "active_support/configurable"
require "rest_client"

module Kynort
  include ActiveSupport::Configurable

  TITLE_MISTER = "Mr"
  TITLE_MS = "Ms"
  TITLE_MRS = "Mrs"

  class << self
    def setup
      config.api_key = nil
      config.secret_key = nil
      config.host = "http://localhost:4001"
    end
  end
end

require "kynort_gem/flights"
require "kynort_gem/normalize_country"