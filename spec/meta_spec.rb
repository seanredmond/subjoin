require "spec_helper"

describe "Subjoin::Meta" do
  before :each do
    @m = Subjoin::Meta.new(JSON.parse(META)['meta'])
  end

  it "has dynamic attributes" do
    expect(@m["copyright"]).to eq "Copyright 2015 Example Corp."
  end
end
