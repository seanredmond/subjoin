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
    context "with a non-subclassed object" do
      it "throws an error" do
        expect { @unsub.type_url }.to raise_exception NoMethodError
      end
    end
    
    context "with and subclassed object" do
      context "when the developer forgot to override ROOT_URI" do
        it "throws an error" do
          expect { @poor.type_url }.to raise_exception Subjoin::SubclassError
        end
      end
      
      context "with automatic type path" do
        it "returns the URI" do
          expect(@sub.type_url).to eq "http://example.com/exampleresource"
        end
      end
      
      context "with non-standard type path" do
        it "returns the URI" do
          expect(@nonstd.type_url).to eq "http://example.com/nonstandard"
        end
      end
    end
  end
end
