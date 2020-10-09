# frozen_string_literal: true

module Helper
  # Interface between Rack and response
  module RackResponse
    # Helper providing a common way to build a response based on http errors
    #
    # @param http_code [Integer] Http error code,
    # please see {https://en.wikipedia.org/wiki/List_of_HTTP_status_codes} for more information
    # @param message [String, nil] Override of the error message that need to be returned
    #
    # @return [Array<Integer, Hash, String>] Status, Header, Body
    def self.respond_with(http_code, message: nil)
      message ||=
        case http_code
        when 200 then :ok
        when 404 then { error: 'Endpoint not supported' }
        when 500 then { error: 'Something went wrong, we are trying to fix the problem!' }
        end

      [http_code, header, [message.to_json]]
    end

    # All of our response header are identical
    # We always want to responde with JSON
    #
    # @return [Hash] the default header
    def self.header
      { 'Content-Type' => 'application/json' }
    end
  end
end
