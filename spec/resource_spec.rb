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
    
    @article = Article.new(1)
  end

  describe "#id" do
    it "should equal the id of the respnse" do
      expect(@article.id).to eq "1"
    end
  end
  
  describe "#root" do
    context "when it has not been overriden" do
      it "should raise an error" do
        class BadBase < Subjoin::Resource; end
        expect { BadBase.new(0) }.to raise_error(Subjoin::NoOverriddenRootError)
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
    it "should make a request to the correct URL" do
      allow_any_instance_of(Faraday::Connection).
        to receive(:get).and_return(double(Faraday::Response))

      expect_any_instance_of(Faraday::Connection)
        .to receive(:get).with("http://example.com/article")

      Article.all
    end
  end

  describe "#new" do
    context "with an id passed as a parameter"  do
      it "should make a request to the correct URL" do
        expect_any_instance_of(Faraday::Connection)
          .to receive(:get).with("http://example.com/article/2")
               .and_return(double(Faraday::Response, :body => ARTICLE))
        Article.new(2)
      end
    end

    context "with an id that will result in an error" do
      it "should raise an error" do
        response_double = double(Faraday::Response, :body => ERR404, :headers => {}, :status => 404)
        allow_any_instance_of(Faraday::Connection).
          to receive(:get).and_return(response_double)
        expect { Article.new(0) }.to raise_error(Subjoin::ResponseError)
      end
    end
  end
end
