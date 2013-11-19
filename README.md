# Chain #

*Abusing `method_missing` since 2013*™

### What in the Sam Hill is Chain? ###

Chain is a simple library that makes it (too) easy to interface with a (non)-RESTful web API. Inspired by [Her](https://github.com/remiprev/her/), I needed a way to create something that mimics an ORM to communicate with a non-RESTful API. Chain uses [Faraday](https://github.com/lostisland/faraday) as the client library to manage requests to API endpoints. As a result, you have full control of how the request and response are parsed out and mapped to an object in Ruby!

### How does it work? ###

Simply instantiate the `Url` class and then chain together a series of methods that represent the URL path. Finish off the chain with a bang to kick off the request. For example:

```ruby
>> require 'chain'

>> site = Chain::Url("http://www.site.com")

>> item = site.items[1].group!
=> #Hashie::Mash of JSON from http://www.site.com/items/1/group

>> item.name
=> "..."
```

This opens up all sorts of clever ways to iterate through an endpoint:

```ruby
# Send a GET request to http://www.site.com/items
items = site.items!

# Assuming that /items returns a JSON object containing a list of items in the `data` attribute...
items.data.each do |item|

   # ...iterate through and print out the `name` attribute for http://www.site.com/items/#
   puts items[item.id]._fetch.name
end
```

### Query Parameters ###

You can specify query parameters via the `[]`, `_fetch`, or `_<insert your favorite http verb here>`. For example:

```ruby
# Submit a GET request to http://www.site.com/users?name=Mark Corrigan

>> user = site.users[name: 'Mark Corrigan'] 
>> user = site[:users, name: 'Mark Corrigan'] 
>> user = site.users._fetch(name: 'Mark Corrigan`)
```

### Other HTTP actions ###

By default, the `!`, `[]`, and `_fetch` methods on a `Url` object will map to a GET request. You can also use `_put`, `_post`, `_head`, `_delete`, etc.

To submit a request with a payload, send a request with the `_body` parameter:

```ruby
# Send a POST request to http://www.site.com/users with URL-encoded parameters in the payload
>> user = site.users._post(_body: {name: 'Mark Corrigan'})
```

You can also manually specify the HTTP verb via `_method` and headers via `_headers`:

```ruby
>> user = site.users._fetch(_method: :post, _body: {name: 'Mark Corrigan'})
>> site.users._fetch(_method: :post, _headers: {"Accept" => "text/plain"})
```

### Configuring the Middleware ###

By default, Chain will assume that the response is JSON and will render that object inside of a [Hashie::Mash](https://github.com/intridea/hashie) object. If you want to implement your own request/response middleware, simply pass in a block to configure the Faraday connection:

```ruby
site = Chain.Url("http://www.site.com") do |connection|
  connection.use Faraday::Request::UrlEncoded
  connection.use MyResponseMiddleWare
  connection.use Faraday::Adapter::NetHttp
end
```

Writing your own middleware is fairly easy. Chain uses something along the lines of:

```ruby
class HashieMashResponse < Faraday::Response::Middleware
  def on_complete(env)
    body = JSON.parse(env[:body])
    headers = env[:response_headers]
    env[:body] = Hashie::Mash.new(body).tap do |item|
      item._headers = Hashie::Mash.new(headers)
      item._status  = env[:status]
    end
  end
end
```

### Bring on the caveats! ###

1. You cannot follow the bracket notation by a bang, such as: `site.person["Mark Corrgian"]!`. Use `site.person["Mark Corrgian"]._fetch`.

2. You cannot pass in a block to the bracket method, such as: `site.person["Mark Corrgian"]{|req| p req['url']}`. Use the `_fetch` method as described above.

3. For any urls that end with an extension, you will need to use the bracket notation. For example, site.users.json would render http://www.site.com/users/json.

4. Any portions of the url path that contain characters not supported by Ruby, you will need to use the bracket notation. This includes path segments that start with numerics, such as http://www.site.com/users/0. (It cannot be rendered as `site.users.0`, but rather `site.users[0]`.)

5. You will not be able to access URL sub-paths that have names similar to methods on standard objects in Ruby. For example, site.users[1].methods (http://www.site.com/users/1/methods) will return you a list of methods on the Chain::Url object. Use bracket notation!
