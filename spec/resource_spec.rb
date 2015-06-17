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
            .to receive(:get).
                 with(URI("http://example.com/articles/2"), {}, Hash).
                 and_return(double(Faraday::Response, :body => ARTICLE))

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
        expect(@article.links.map{|k,v| v.class}.uniq).to eq [Subjoin::Link]
      end
    end

    context "with a parameter" do
      it "returns a link object" do
        expect(@article.links["self"]).to be_an_instance_of Subjoin::Link
      end
    end
  end

  describe "#rels" do
    context "when there are included resources" do
      before :each do
        allow_any_instance_of(Faraday::Connection).
          to receive(:get).
              and_return(double(Faraday::Response, :body => COMPOUND))
        @article = Subjoin::Document.new(URI("http://example.com/articles/1")).
                   data.first
      end
      
      context "called with no parameters" do
        it "returns a Hash of Arrays of Relationship objects" do
          expect(@article.rels.map{|k, r| r}.flatten.map{|r| r.class}.uniq).
            to eq [Subjoin::Resource]
        end
      end
      
      context "called with a spec parameter" do
        it "returns an array" do
          expect(@article.rels("author").map{|r| r.class}).
            to eq [Subjoin::Resource]
        end
      end
    end

    context "when there are no included resources" do
      before :each do
        @article = Subjoin::Resource.new(URI("http://example.com/articles/1"))
      end
      
      context "called with no spec parameter" do
        it "returns nil" do
          expect(@article.rels).to be_nil
        end
      end

      context "called with a spec parameter" do
        it "returns nil" do
          expect(@article.rels("author")).to be_nil
        end
      end
    end
  end

  describe "#meta" do
    before :each do
      @article = Subjoin::Resource.new(URI("http://example.com/articles/1"))
    end

    it "returns a Meta object" do
      expect(@article.meta).to be_an_instance_of Subjoin::Meta
    end
  end
end
