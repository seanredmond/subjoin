require "spec_helper"

describe Subjoin do
  describe "#get" do
    before :each do
      allow_any_instance_of(Faraday::Connection).
        to receive(:get).and_return(double(Faraday::Response, :body => ARTICLE))
    end
      
    it "should return parsed JSON" do
      expect(Subjoin::get(URI("http://example.com/articles"))).
        to be_an_instance_of(Hash)
    end
  end

  describe "#document" do
    context "with a compound document response" do
      before :each do
        allow_any_instance_of(Faraday::Connection).
          to receive(:get).
              and_return(double(Faraday::Response, :body => COMPOUND))
      end
      
      it "should return a Document" do
        expect(Subjoin::document(URI("http://example.com/articles"))).
          to be_an_instance_of(Subjoin::Document)
      end
    end

    context "with a single resource response" do
      before :each do
        allow_any_instance_of(Faraday::Connection).
          to receive(:get).
              and_return(double(Faraday::Response, :body => ARTICLE))
      end
      
      it "should return a Document" do
        expect(Subjoin::document(URI("http://example.com/articles/1"))).
          to be_an_instance_of(Subjoin::Document)
      end
    end

    context "with an error response" do
      before :each do
        allow_any_instance_of(Faraday::Connection).
          to receive(:get).
              and_return(double(Faraday::Response, :body => ERR404))
      end
      
      it "should return a Resource" do
        expect { Subjoin::document(URI("http://example.com/articles/1"))}.
          to raise_error Subjoin::ResponseError
      end
    end
  end
end
