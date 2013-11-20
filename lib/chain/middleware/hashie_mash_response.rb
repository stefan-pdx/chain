module Chain
  module Middleware
    class HashieMashResponse < Faraday::Response::Middleware
      def on_complete(env)
        case env[:status]
        when 200
          body    = env[:body].to_s.encode('UTF-8', {invalid: :replace, undef: :replace, replace: '?'})

          json    = JSON.parse(body)
          headers = env[:response_headers]

          env[:body] = Hashie::Mash.new(json).tap do |item|
            item._headers = Hashie::Mash.new(headers)
            item._status  = env[:status]
          end
        else
          raise Chain::Middleware::RequestError, env[:status]
        end

      rescue JSON::ParserError => ex
        raise Chain::Middleware::ParseError, "Unable to parse JSON response: #{ex.message}"

      rescue NoMethodError => ex
        # This captures parsing errors from Hashie::Mash. Unfortunately, HM does not raise
        # their own errors.
        raise Chain::Middleware::ParseError, "Unable to parse JSON as object: #{ex.message}"
      end
    end
  end
end
