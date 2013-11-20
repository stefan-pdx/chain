module Chain
  module Middleware
    class ParseError < StandardError
      def initialize(message)
        super(message)
      end
    end
  end
end
