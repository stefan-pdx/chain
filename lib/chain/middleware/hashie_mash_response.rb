module Chain
  module Middleware
    class HashieMashResponse < Faraday::Response::Middleware
      def on_complete(env)
        body = JSON.parse(env[:body].to_s.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'}))
        headers = env[:response_headers]
        env[:body] = Hashie::Mash.new(body).tap do |item|
          item._headers = Hashie::Mash.new(headers)
          item._status  = env[:status]
        end
      end
    end
  end
end
