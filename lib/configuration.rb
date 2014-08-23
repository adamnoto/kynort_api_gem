module Kynort
  def self.configure(configuration = Kynort::Configuration.new)
    yield configuration if block_given?
    @@configuration = configuration
  end

  def self.configuration # :nodoc:
    @@configuration ||= Kynort::Configuration.new
  end

  # Kynort can be configured using the Kynort.configure method. For example:
  #
  #   Kynort.configure do |config|
  #     config.app_id = "ABC"
  #     config.secret_key = "XYZ"
  #     config.apphost = "http://localhost"
  #   end
  class Configuration
    attr_accessor :app_id
    attr_accessor :secret_key
    attr_accessor :apphost
  end
end