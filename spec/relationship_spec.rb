require "spec_helper"


describe Subjoin::Relationship do
  before :all do
    @doc = Subjoin::Document.new(JSON.parse(COMPOUND))
    @auths = @doc.data.first.relationships["author"]
  end

  it "is linkable" do
    expect(@auths.links.map{|k,v| v.class}.uniq).to eq [Subjoin::Link]
  end

  it "has the right links" do
    expect(@auths.links.keys).to eq ["self", "related"]
  end

  it "has a meta object" do
    expect(@auths.meta).to be_an_instance_of Subjoin::Meta
  end

  describe "#lookup" do
    it "returns an Array of resources" do
      expect(@auths.lookup.map{|o| o.class}.uniq).to eq [Subjoin::Resource]
    end
  end

  describe "#linkages" do
    context "with a single linkage" do
      it "returns an Array" do
        expect(@auths.linkages).to be_an_instance_of Array
      end

      it "returns an array with a single member" do
        expect(@auths.linkages.count).to eq 1
      end
        
      it "returns an array of Identifier objects" do
        expect(@auths.linkages.map{|l| l.class}.uniq).to eq [Subjoin::Identifier]
      end
    end

    context "with an array of linkages" do
      before :each do
        @comments = Subjoin::Relationship.new(
          JSON.parse(ARTICLE)['data']['relationships']['comments'],
          nil
        )
      end      

      it "returns an Array" do
        expect(@comments.linkages).to be_an_instance_of Array
      end

      it "returns an array with more than 1 member" do
        expect(@comments.linkages.count).to be > 1
      end
        
      it "returns an array of Identifier objects" do
        expect(@comments.linkages.map{|l| l.class}.uniq).to eq [Subjoin::Identifier]
      end
    end
  end
end
