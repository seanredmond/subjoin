require "spec_helper"

describe Subjoin do
  describe "#get" do
    it "should return parsed JSON" do
      allow_any_instance_of(Faraday::Connection).
        to receive(:get).and_return(double(Faraday::Response, :body => ARTICLE))
      expect(Subjoin::get(URI("http://example.com/articles"))).
        to be_an_instance_of(Hash)
    end

    context "with a hash of parameters" do
      before :each do
        expect_any_instance_of(Faraday::Connection).
          to receive(:get).
              with(URI, hash_including("include" => "author,comments")).
              and_return(double(Faraday::Response, :body => ARTICLE))
      end
        
      context "and String for an include parameter" do
        it "should get the URI with the parameter" do
          Subjoin::get(URI("http://example.com/articles"),
                       {"include" => "author,comments"})
        end
      end

      context "and an array of Strings for an include parameter" do
        it "should join the array into a string" do
          Subjoin::get(URI("http://example.com/articles"),
                       {"include" => ["author", "comments"]})
        end
      end
    end
  end
end
