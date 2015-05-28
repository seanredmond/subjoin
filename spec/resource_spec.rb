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

  context "using class methods to retrieve collections of objects" do
    describe "#get" do
      it "should return parsed JSON" do
        expect(Subjoin::Resource.get(URI("http://example.com/articles"))).
          to be_an_instance_of(Hash)
      end
    end

    describe "resources" do
      before :each do
        allow_any_instance_of(Faraday::Connection).
          to receive(:get).
              and_return(double(Faraday::Response, :body => COMPOUND))
      end
      
      it "should return parsed JSON" do
        expect(Subjoin::Resource.resources(URI("http://example.com/articles/1"))).
          to be_an_instance_of(Hash)
      end
    end
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
