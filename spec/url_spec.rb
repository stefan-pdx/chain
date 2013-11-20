require 'spec_helper'

describe Chain::Url do

  context 'with HashieMashMiddleware' do

    subject do
      described_class.new('http://test.com')
    end

    describe 'response payloads' do

      before :each do
        body = {data: true}.to_json

        stub_request(:get, 'http://test.com/item').
          to_return(status: 200, body: body) 
      end

      after :each do
        a_request(:get, 'http://test.com/item').
          should have_been_made

        expect(@item.data).to eq(true)
      end

      it 'should return a response payload using the bang method' do
        @item = subject.item!
      end

      it 'should return a response payload using the _fetch method' do
        @item = subject.item._fetch
      end

      it 'should parse a request url using the bracket method' do
        @item = subject['item']._fetch
      end
    end

    describe 'http verbs' do

      [:get, :put, :post, :delete, :head, :patch].each do |verb|
        it "should make valid request using the _#{verb} syntax" do
          body = {data: true}.to_json

          stub_request(verb, 'http://test.com/item').
            to_return(status: 200, body: body) 

          subject.item.send("_#{verb}")

          a_request(verb, 'http://test.com/item').
            should have_been_made
        end
      end
    end

    describe 'request parsing' do

      before :each do
        body = {data: true}.to_json

        stub_request(:get, 'http://test.com/item').
          to_return(status: 200, body: body) 

        stub_request(:get, 'http://test.com/a/b/c/d/e/f/g').
          to_return(status: 200, body: body) 

        stub_request(:get, 'http://test.com/item').
          with(query: {foo: 'bar'}).
          to_return(status: 200, body: body) 

        stub_request(:post, 'http://test.com/item').
          to_return(status: 200, body: body) 
      end

      it 'should parse chained methods as a nested url path' do
        subject.a.b.c.d.e.f.g!

        a_request(:get, 'http://test.com/a/b/c/d/e/f/g').
          should have_been_made
      end

      it 'should take keyword arguments from bracket notion and expend them out as parameters' do
        subject.item[foo: 'bar']._fetch

        a_request(:get, 'http://test.com/item').
          with(query: hash_including({'foo' => 'bar'})).
          should have_been_made
      end

      it 'should generate a request if a hash is passed into a method' do
        subject.item(foo: 'bar')

        a_request(:get, 'http://test.com/item').
          with(query: hash_including({'foo' => 'bar'})).
          should have_been_made
      end

      it 'should parse the _method parameter as the HTTP request type' do
        subject.item[_method: :post]._fetch

        a_request(:post, 'http://test.com/item').
          should have_been_made
      end

      it 'should parse the _body parameter as the HTTP request type' do
        subject.item[_method: :post, _body: 'foo=bar']._fetch

        a_request(:post, 'http://test.com/item').
          with(body: 'foo=bar').
          should have_been_made
      end

      it 'should parse the _headers parameter as the HTTP request headers' do
        subject.item[:_headers => {'Content-Length' => '3'}]._fetch

        a_request(:get, 'http://test.com/item').
          with(headers: {'Content-Length' => '3'}).
          should have_been_made
      end
    end

    describe 'modifying Faraday requests' do

      before :each do
        body = {data: true}.to_json

        stub_request(:get, 'http://test.com/item').
          with(query: {foo: 'bar'}).
          to_return(status: 200, body: body) 
      end

      it 'should be able to modify the request object as a request is made' do
        subject.item do |request|
          request.params['foo'] = 'bar'
        end

        a_request(:get, 'http://test.com/item').
          with(query: hash_including({'foo' => 'bar'})).
          should have_been_made
      end
    end
  end

  context 'with HashieMashMiddleware and default parameters' do

    subject do
      described_class.new('http://test.com', _default_parameters: {foo: 'bar'})
    end

    describe 'request parsing' do

      before :each do
        body = {data: true}.to_json

        stub_request(:get, 'http://test.com/item').
          with(query: {foo: 'bar'}).
          to_return(status: 200, body: body) 

        stub_request(:post, 'http://test.com/item').
          to_return(status: 200, body: body) 
      end

      it 'should parse out a url with default_parameters specified by the base url instance' do
        subject.item!

        a_request(:get, 'http://test.com/item').
          with(query: hash_including({'foo' => 'bar'})).
          should have_been_made
      end
    end
  end
end
