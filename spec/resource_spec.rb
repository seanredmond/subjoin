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

      context "passing a hash as a parameter" do
        it "should succeed" do
          expect(Subjoin::Resource.new(JSON.parse(ARTICLE)).id).to eq "1"
        end
      end
    end
  end

  describe "simple methods" do
    before :each do
      @article = Subjoin::Resource.new(URI("http://example.com/articles/1"))
    end

    it "should have an id" do
      expect(@article.id).to eq "1"
    end

    it "should have a type" do
      expect(@article.type).to eq "articles"
    end

    it "should have automatic attributes" do
      expect(@article["title"]).to eq "JSON API paints my bikeshed!"
    end
  end

  describe "#links" do
    before :each do
      @article = Subjoin::Resource.new(URI("http://example.com/articles/1"))
    end

    context "with no parameter" do
      it "returns a Hash of all the links" do
        expect(@article.links).to be_an_instance_of Subjoin::Links
      end
    end

    context "with a parameter" do
      it "returns a link object" do
        expect(@article.links["self"]).to be_an_instance_of Subjoin::Link
      end
    end
  end

  context "using inheritance" do
    before :each do
      allow_any_instance_of(Faraday::Connection).
        to receive(:get).and_return(double(Faraday::Response, :body => ARTICLE))
      @sub    = ExampleResource.new(URI("http://example.com/articles/1"))
      @nonstd = NonStandardUri.new(URI("http://example.com/articles/1"))
      @unsub  = Subjoin::Resource.new(URI("http://example.com/articles/1"))
      @poor   = PoorlySubclassed.new(URI("http://example.com/articles/1"))
    end

    it "has a root uri" do
      expect(ExampleResource::ROOT_URI).to eq "http://example.com"
    end

    it "has a different class" do
      expect(@sub.class).to eq ExampleResource
    end

    describe "#type_url" do
      context "with a non-subclassed object" do
        it "throws an error" do
          expect { @unsub.type_url }.to raise_exception Subjoin::SubclassError
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
end
