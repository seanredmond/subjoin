require "spec_helper"

describe Subjoin::Identifier do
  before :each do
    data = JSON.parse(ARTICLE)['data']['relationships']['author']
    @id = Subjoin::Identifier.
          new(data['data']['type'], data['data']['id'], data['meta'])
  end

  it "has a type" do
    expect(@id.type).to eq "people"
  end

  it "has an id" do
    expect(@id.id).to eq "9"
  end

  it "has a Meta object" do
    expect(@id.meta).to be_an_instance_of Subjoin::Meta
  end

  describe "equality" do
    it "is equal if #type and #id are the same" do
      other = Subjoin::Identifier.new("people", "9")
      expect(@id == other).to be true
    end

    it "is other not equal" do
      other = Subjoin::Identifier.new("schmeople", "9")
      expect(@id == other).to be false
    end
  end
end
