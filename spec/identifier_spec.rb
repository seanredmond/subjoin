require "spec_helper"

describe Subjoin::Identifier do
  before :each do
    @id = Subjoin::Identifier.new(
      JSON.parse(ARTICLE)['data']['relationships']['author']['data']
    )
  end

  it "has a type" do
    expect(@id.type).to eq "people"
  end

  it "has an id" do
    expect(@id.id).to eq "9"
  end

  it "has a key" do
    expect(@id.key).to be_an_instance_of Subjoin::Key
  end
end
