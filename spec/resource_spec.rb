require "spec_helper"

class Base < Subjoin::Resource
  def self.root
    "http://example.com"
  end
end

class Article < Base
end

describe Subjoin::Resource do
  before :each do
    allow_any_instance_of(Faraday::Connection).
      to receive(:get).and_return(double(Faraday::Response, :body => ARTICLE))
  end

  context "using instance methods to retrieve single resources" do
    describe "#initialize" do
      context "passing a URI as a parameter" do
        it "should get the same a parameter" do
          expect_any_instance_of(Faraday::Connection)
            .to receive(:get).with(URI("http://example.com/articles/2"))
                 .and_return(double(Faraday::Response, :body => ARTICLE))

          @articles = Subjoin::Resource.
                      new(URI("http://example.com/articles/2"))
          
        end

        it "should raise an error if the response is not a single object" do
          expect_any_instance_of(Faraday::Connection)
            .to receive(:get)
                 .and_return(double(Faraday::Response, :body => COMPOUND))
          expect { Subjoin::Resource.
                   new(URI("http://example.com/articles")) }
            .to raise_error(Subjoin::UnexpectedTypeError)
        end
      end
    end
  end
end
