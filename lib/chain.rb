require "uri"
require "json"

require "faraday"
require "hashie"

require "chain/url"
require "chain/version"
require "chain/middleware/hashie_mash_response"
require "chain/middleware/parse_error"
require "chain/middleware/request_error"
