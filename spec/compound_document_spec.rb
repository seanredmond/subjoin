require "spec_helper"

describe Subjoin::CompoundDocument do
  before :each do
    @cd = Subjoin::CompoundDocument.new(JSON.parse(COMPOUND))
  end

  describe "#resources" do
    it "should be an Array" do
      expect(@cd.resources).to be_an_instance_of Array
    end

    it "should be an Array of Resource objects" do
      expect(@cd.resources.map{|r| r.class}.uniq).to eq [Subjoin::Resource]
    end

    it "should have the right Resource objects" do
      expect(@cd.resources.first.key).to eq Subjoin::Key.new("articles", "1")
    end
  end

  describe "#included" do
    it "should be an Array" do
      expect(@cd.included).to be_an_instance_of Array
    end

    it "should be an Array of Resource objects" do
      expect(@cd.included.map{|r| r.class}.uniq).to eq [Subjoin::Resource]
    end

    it "should have the right Resource objects" do
      expect(@cd.included.first.key).to eq Subjoin::Key.new("people", "9")
    end
  end
end
