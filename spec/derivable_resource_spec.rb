require "spec_helper"

module Subjoin
  class ExampleResource < Subjoin::DerivableResource
    ROOT_URI="http://example.com"
  end

  class NonStandardUri < ExampleResource
    TYPE_PATH="nonstandard"
  end

  class PoorlySubclassed < Subjoin::DerivableResource
  end
end

describe Subjoin::DerivableResource do
  before :each do
    allow_any_instance_of(Faraday::Connection).
      to receive(:get).and_return(double(Faraday::Response, :body => ARTICLE))
    @sub    = Subjoin::ExampleResource.new(URI("http://example.com/articles/1"))
    @nonstd = Subjoin::NonStandardUri.new(URI("http://example.com/articles/1"))
    @unsub  = Subjoin::Resource.new(URI("http://example.com/articles/1"))
    @poor   = Subjoin::PoorlySubclassed.new(URI("http://example.com/articles/1"))
  end
  
  it "has a root uri" do
    expect(Subjoin::ExampleResource::ROOT_URI).to eq "http://example.com"
  end
  
  it "has a different class" do
    expect(@sub.class).to eq Subjoin::ExampleResource
  end
  
  describe "#type_url" do
    it "is a class method" do
      expect(Subjoin::ExampleResource::type_url).to eq "http://example.com/exampleresource"
    end
  end
end
