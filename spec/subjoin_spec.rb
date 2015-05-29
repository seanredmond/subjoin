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

  describe "resources" do
    before :each do
      allow_any_instance_of(Faraday::Connection).
        to receive(:get).
            and_return(double(Faraday::Response, :body => COMPOUND))
    end
      
    it "should return parsed JSON" do
      expect(Subjoin::resources(URI("http://example.com/articles/1"))).
        to be_an_instance_of(Hash)
    end
  end
end
