require "spec_helper"

describe Subjoin::Inclusions do
  before :all do
    @doc = Subjoin::Document.new(JSON.parse(COMPOUND))
  end

  describe "#all" do
    it "returns an Array" do
      expect(@doc.included.all).to be_an_instance_of Array
    end
  end

  describe "#[]" do
    context "when passed an Identifier" do
      context "when the Identifier matches something included" do
        it "returns a Resource" do
          id = Subjoin::Identifier.new("people", "9")
          expect(@doc.included[id]).to be_an_instance_of Subjoin::Resource
        end

        it "returns to expected Resource" do
          id = Subjoin::Identifier.new("people", "9")
          expect(@doc.included[id]['twitter']).to eq "dgeb"
        end
      end
    end

    context "when passed an Array" do
      context "when the Identifier matches something included" do
        it "returns a Resource" do
          expect(@doc.included[["people", "9"]]).
            to be_an_instance_of Subjoin::Resource
        end

        it "returns to expected Resource" do
          expect(@doc.included[["people", "9"]]['twitter']).to eq "dgeb"
        end
      end
    end

    context "when nothing matched" do
      it "returns nil" do
        expect(@doc.included[["people", "99"]]).
          to be_nil
      end
    end
  end
end
  
