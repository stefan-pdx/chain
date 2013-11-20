require 'spec_helper'

describe Chain::Middleware::HashieMashResponse do

  subject do
    described_class.new
  end

  describe '#on_complete' do

    context 'a valid response response with a 200 status' do
      let(:env){{body: {success: true}.to_json, status: 200}}

      it 'should yield a Hashie::Mash object from the request' do
        subject.on_complete(env)
        expect(env[:body].success).to be true
      end
    end

    context 'a response with invalid json' do
      let(:env){{body: "[1,2,3]", status: 200}}

      it 'should raise a ParseError instance' do
        expect { subject.on_complete(env) }.to raise_error(Chain::Middleware::ParseError)
      end
    end

    context 'a response with a 404 status' do
      let(:env){{body: nil, status: 404}}

      it 'should raise an instance of RequestError with a 404 status code' do
        expect { subject.on_complete(env) }.to raise_error do |exception|
          expect(exception.status_code).to eq(404) 
        end
      end
    end
  end
end
