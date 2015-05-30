require "spec_helper"

describe Subjoin::Key do
  before :each do
    @k = Subjoin::Key.new("articles", "1")
  end

  it "has a #type" do
    expect(@k.type).to eq "articles"
  end

  it "has an #id" do
    expect(@k.id).to eq "1"
  end

  describe "#==" do
    it "is true when two objects have the same type and id" do
      @o = Subjoin::Key.new("articles", "1")
      expect(@k == @o).to eq true
    end

    it "is false when the type differs" do
      @o = Subjoin::Key.new("schmarticles", "1")
      expect(@k == @o).to eq false
    end

    it "is false when the id differs" do
      @o = Subjoin::Key.new("articles", "11")
      expect(@k == @o).to eq false
    end

    it "is false when both the type and id differ" do
      @o = Subjoin::Key.new("schmarticles", "11")
      expect(@k == @o).to eq false
    end
  end
end
    
