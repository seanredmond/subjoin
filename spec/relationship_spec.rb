require "spec_helper"


describe Subjoin::Relationship do
  before :each do
    @r = Subjoin::Relationship.new(
      JSON.parse(ARTICLE)['data']['relationships']['author']
    )
  end

  it "is linkable" do
    expect(@r.links).to be_an_instance_of(Subjoin::Links)
  end

  it "has the right links" do
    
    expect(@r.links.keys).to eq ["self", "related"]
  end
    
end
