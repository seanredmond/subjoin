require "spec_helper"

module Subjoin
  class ExampleResource < Subjoin::InheritableResource
    ROOT_URI="http://example.com"
  end

  class NonStandardUri < ExampleResource
    TYPE_PATH="nonstandard"
  end

  class PoorlySubclassed < Subjoin::InheritableResource
  end

  class ExampleArticle < ExampleResource
    TYPE_PATH="articles"
  end
end

describe Subjoin::InheritableResource do
  before :each do
    allow_any_instance_of(Faraday::Connection).
      to receive(:get).and_return(double(Faraday::Response, :body => ARTICLE))
    @sub    = Subjoin::ExampleResource.new(URI("http://example.com/articles/1"))
    @nonstd = Subjoin::NonStandardUri.new(URI("http://example.com/articles/1"))
    @unsub  = Subjoin::Resource.new(URI("http://example.com/articles/1"))
    @poor   = Subjoin::PoorlySubclassed.new(URI("http://example.com/articles/1"))
    Subjoin::Document.new({})
  end
  
  it "has a root uri" do
    expect(Subjoin::ExampleResource::ROOT_URI).to eq "http://example.com"
  end
  
  it "has a different class" do
    expect(@sub.class).to eq Subjoin::ExampleResource
  end
  
  describe "#type_url" do
    it "is a class method" do
      expect(Subjoin::ExampleResource::type_url).to eq URI("http://example.com/exampleresource")
    end
  end
end

describe Subjoin::Document do
  describe "#new" do
    context "with a single string parameter" do
      it "maps derived types" do
        expect_any_instance_of(Faraday::Connection)
          .to receive(:get).with(URI("http://example.com/articles"), {})
               .and_return(double(Faraday::Response, :body => ARTICLE))
        Subjoin::Document.new("articles")
      end
    end

    context "with two string parameters" do
      it "maps derived types with the second string as an id" do
        expect_any_instance_of(Faraday::Connection)
          .to receive(:get).with(URI("http://example.com/articles/2"), {})
               .and_return(double(Faraday::Response, :body => ARTICLE))
        Subjoin::Document.new("articles", "2")
      end
    end
  end
end
      
  
