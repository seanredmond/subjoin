require "spec_helper"


describe Subjoin::Links do
  before :each do
    @l = Subjoin::Links.new(
      JSON.parse(ARTICLE)['data']['relationships']['author']['links']
    )
  end

  it "has keys" do
    expect(@l.keys).to eq ["self", "related"]
  end

  it "returns Link objects by key" do
    expect(@l["related"].to_s).to eq "http://example.com/articles/1/author"
  end
end
