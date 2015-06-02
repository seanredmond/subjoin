require "spec_helper"

describe Subjoin::Document do
  before :all do
    rsp = JSON.parse(COMPOUND)
    @doc = Subjoin::Document.new(rsp)

    dataless = JSON.parse(COMPOUND)
    dataless.delete("data")
    @nodata = Subjoin::Document.new(dataless)

    excluded = JSON.parse(COMPOUND)
    excluded.delete("included")
    @noincl = Subjoin::Document.new(excluded)

    linkless = JSON.parse(COMPOUND)
    linkless.delete("links")
    @nolinks = Subjoin::Document.new(linkless)

    metaless = JSON.parse(COMPOUND)
    metaless.delete("meta")
    @nometa = Subjoin::Document.new(metaless)

    versionless = JSON.parse(COMPOUND)
    versionless.delete("jsonapi")
    @noversion = Subjoin::Document.new(versionless)

    @simple = Subjoin::Document.new(JSON.parse(ARTICLE))
  end

  describe "#data" do
    context "when there is primary data" do
      it "is an Array" do
        expect(@doc.data).to be_an_instance_of Array
      end

      it "contains an expected Resource" do
        expect(@doc.data.first["title"]).to eq "JSON API paints my bikeshed!"
      end
    end

    context "when there is no primary data" do
      it "is nil" do
        expect(@nodata.data).to be_nil
      end
    end

    context "when there is a single object in primary data" do
      it "is still an Array" do
        expect(@simple.data).to be_an_instance_of Array
      end

      it "has one element" do
        expect(@simple.data.count).to eq 1
      end
    end
  end

  describe "#has_data?" do
    context "when there is primary data" do
      it "returns true" do
        expect(@doc.has_data?).to be true
      end
    end

    context "when there is no primary data" do
      it "returns false" do
        expect(@nodata.has_data?).to be false
      end
    end
  end


  describe "#included" do
    context "when there are included resources" do
      it "is an Array" do
        expect(@doc.included).to be_an_instance_of Subjoin::Inclusions
      end

      it "contains an expected Resource" do
        expect(@doc.included[0].type).to eq "people"
      end
    end

    context "when there are no included resources" do
      it "is nil" do
        expect(@noincl.included).to be_nil
      end
    end
  end

  describe "#has_included?" do
    context "when there are included resources" do
      it "returns true" do
        expect(@doc.has_included?).to be true
      end
    end

    context "when there are no included resources" do
      it "returns false" do
        expect(@noincl.has_included?).to be false
      end
    end
  end

  describe "#links" do
    context "when there are links" do
      it "is a Links object" do
        expect(@doc.links).to be_an_instance_of(Subjoin::Links)
      end

      it "has an expected link" do
        expect(@doc.links["related"].to_s).to eq "http://jsonapi.org"
      end
    end

    context "when there are no links" do
      it "is nil" do
        expect(@nolinks.links).to be_nil
      end
    end
  end
  
  describe "#has_links?" do
    context "when there are links" do
      it "returns true" do
        expect(@doc.has_links?).to be true
      end
    end

    context "when there no links" do
      it "returns false" do
        expect(@nolinks.has_links?).to be false
      end
    end
  end

  describe "#meta" do
    context "when there is meta information" do
      it "is a Meta object" do
        expect(@doc.meta).to be_an_instance_of(Subjoin::Meta)
      end

      it "has an expected attribute" do
        expect(@doc.meta["category"]).to eq "Example response"
      end
    end

    context "when there is no meta information" do
      it "is nil" do
        expect(@nometa.meta).to be nil
      end
    end
  end

  describe "#has_meta?" do
    context "when there is meta information" do
      it "returns true" do
        expect(@doc.has_meta?).to be true
      end
    end

    context "when there is no meta information" do
      it "returns false" do
        expect(@nometa.has_meta?).to be false
      end
    end
  end

  describe "#jsonapi" do
    context "when there is version information" do
      it "is a JsonApi object" do
        expect(@doc.jsonapi).to be_an_instance_of(Subjoin::JsonApi)
      end

      it "has an expected attribute" do
        expect(@doc.jsonapi.version).to eq "1.0"
      end
    end

    context "when there is no version information" do
      it "is nil" do
        expect(@noversion.jsonapi).to be nil
      end
    end
  end

  describe "#has_jsonapi?" do
    context "when there is version information" do
      it "returns true" do
        expect(@doc.has_jsonapi?).to be true
      end
    end

    context "when there is no version information" do
      it "returns false" do
        expect(@noversion.has_jsonapi?).to be false
      end
    end
  end

  context "instantiated with a URI" do
    it "succeeds" do
      allow_any_instance_of(Faraday::Connection).
        to receive(:get).and_return(double(Faraday::Response, :body => ARTICLE))
      expect(Subjoin::Document.new(URI("http://example.com/articles"))).
        to be_an_instance_of(Subjoin::Document)
    end
  end
end
