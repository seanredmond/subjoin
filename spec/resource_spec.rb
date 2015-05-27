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
    @article = Article.new
  end

  describe "#root" do
    context "when it has not been overriden" do
      it "should raise an error" do
        class BadBase < Subjoin::Resource; end
        bb = BadBase.new
        expect { bb.root }.to raise_error(Subjoin::NoOverriddenRootError)
      end
    end
    
    context "when it has been overriden" do
      it "should be a URL" do
        expect(@article.root).to eq "http://example.com"
      end
    end
  end

  describe "#classname" do
    it "should be a lowercased version of the class" do
      expect(@article.classname).to eq "article"
    end
  end

  describe "#request_path" do
    it "should return the correct combo of root and name" do
      expect(@article.request_path).to eq "http://example.com/article"
    end
  end

  describe "#all" do
    before :all do
                                                     
    end

    it "should make a request to the correct URL" do
      allow_any_instance_of(Faraday::Connection).
        to receive(:get).and_return(double(Faraday::Response))

      expect_any_instance_of(Faraday::Connection)
        .to receive(:get).with("http://example.com/article")

      Article.all
    end
  end
end
