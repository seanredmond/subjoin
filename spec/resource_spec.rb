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
