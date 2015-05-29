require "spec_helper"

describe Subjoin::Link do
  context "initialization with a string" do
    before :each do
      @link = Subjoin::Link.new(JSON.parse(LINKS)["self"])
    end

    it "should have an href attribute" do
      expect(@link.href).to eq "http://example.com/posts"
    end

    it "should have a nil meta attribute" do
      expect(@link.meta).to be_nil
    end
  end

  context "initialization with an object" do
    before :each do
      @link = Subjoin::Link.new(JSON.parse(LINKS)["related"])
    end

    it "should have an href attribute" do
      expect(@link.href).to eq "http://example.com/articles/1/comments"
    end

    it "should have a meta attribute" do
      expect(@link.meta).to be_an_instance_of Hash
    end
  end

  describe "#has_meta?" do
    it "should be false if there is no meta attribute" do
      expect(Subjoin::Link.new(JSON.parse(LINKS)["self"]).has_meta?).
        to eq false
    end

    it "should be true if there is a meta attribute" do
      expect(Subjoin::Link.new(JSON.parse(LINKS)["related"]).has_meta?).
        to eq true
    end
  end

  describe "#to_s" do
    it "should return the href" do
      expect(Subjoin::Link.new(JSON.parse(LINKS)["self"]).to_s).
        to eq "http://example.com/posts"
    end
  end
end
