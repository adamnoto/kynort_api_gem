class Kynort::Flights::Response
  attr_accessor :is_error
  attr_accessor :error_message
  attr_accessor :raw

  alias_method :is_error?, :is_error
end
