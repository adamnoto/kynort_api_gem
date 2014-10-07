class ApiRequest
  attr_accessor :request_exist
  attr_accessor :guid
  attr_accessor :requested_at
  attr_accessor :status
  attr_accessor :error_description
  attr_accessor :description

  def initialize(options = {})
    @request_exist = options["request_exist"]
    @guid = options["guid"]
    @requested_at = options["requested_at"]
    @status = options["status"]
    @error_description = options["error_description"]
    @description = options["description"]
  end
end