module Chain
  module Middleware
    class RequestError < StandardError
      attr_reader :error_code

      def initialize(error_code)
        @error_code = error_code
        super("HTTP Response Code: #{error_code}")
      end
    end
  end
end
