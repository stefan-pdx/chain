module Chain
  class Url
    attr_accessor :connection, :default_parameters

    def initialize(url, base_url=nil, params={}, &block)
      @url = url

      # Shift method arguments
      if base_url.is_a? Hash
        base_url, params = nil, base_url
      end

      @base_url = base_url

      @default_parameters = params.delete(:_default_parameters)

      if base_url.nil?
        # If no base_url is given, then this is a 'base' instance of a Url. If a block is given,
        # yield our connection object to the block so that the base instance can have its own
        # Faraday configuration
        @connection = Faraday.new(url: @url) do |connection|
          if block_given?
            yield connection
          else
            connection.use Faraday::Request::UrlEncoded
            connection.use Middleware::HashieMashResponse
            connection.use Faraday::Adapter::NetHttp
          end
        end
      else
        # If this is a new instance with a base_url (from method_missing, let's say), then we're
        # going to yield a request object to the block so a user can configure it.
        if block_given?
          _fetch(params, &block)
        end
      end
    end

    def method_missing(method_name, path=nil, params={}, &block)
      if path.is_a? Hash
        path, params = nil, path.merge(params) 
      end

      # If this is a bang method, prepare to run a _fetch.
      is_bang_method = method_name.to_s.chars.last == "!"
      method_name = method_name[0...-1] if is_bang_method

      # If a subsequent path is given as an argument, then expand out the path appropriately.
      # For example, we might have base.api.items("My item", f: 'json'){|request| ...}. This
      # should call into #{base}/api/items/My%20Item?f=json
      combined_path = [method_name, path].compact.join("/")

      # If the combined_path is empty (i.e., we're just evaluating parameters from bracket
      # notation), then we're just going to reuse the url Otherwise, assume that combined_path 
      # appends onto the path.
      url = combined_path.empty? ? @url : URI.join("#{@url}/", combined_path)

      self.class.new(url, @base_url || self, params, &block).tap do |request|
        return request._fetch(params, &block) if is_bang_method || !params.empty?
      end
    end

    def [](path=nil, params={})
      if path.is_a? Hash
        path, params = nil, path.merge(params) 
      end

      method_missing(nil, path, **params)
    end

    def _fetch(params={}, &block)
      http_method = params.delete(:_method) || :get
      body        = params.delete(:_body)
      headers     = params.delete(:_headers)

      @base_url.connection.run_request(http_method, @url, body, headers){|request|
        request.params.update(params) if params
        request.params.update(@base_url.default_parameters) if @base_url.default_parameters
        yield request if block_given?
      }.body
    end

    %w[get head delete post put patch].each do |verb|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def _#{verb}(params={}, &block)
          params.merge!(_method: :#{verb})
          _fetch(params, &block)
        end
      RUBY
    end
  end
end
