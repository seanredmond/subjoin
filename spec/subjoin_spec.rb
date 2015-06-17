require "spec_helper"

describe Subjoin do
  describe "#get" do
    it "should return parsed JSON" do
      allow_any_instance_of(Faraday::Connection).
        to receive(:get).and_return(double(Faraday::Response, :body => ARTICLE))
      expect(Subjoin::get(URI("http://example.com/articles"))).
        to be_an_instance_of(Hash)
    end

    it "should send the correct accept header" do
      allow_any_instance_of(Faraday::Connection).
        to receive(:get).
            with(
              URI,
              Hash,
              hash_including("Accept" => "application/vnd.api+json")
            ).and_return(double(Faraday::Response, :body => ARTICLE))
      Subjoin::get(URI("http://example.com/articles"))
    end

    context "with a hash of parameters" do
      context "including include" do
        before :each do
          expect_any_instance_of(Faraday::Connection).
            to receive(:get).
                with(URI, hash_including("include" => "author,comments"), Hash).
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

      context "including fields" do
        before :each do
          expect_any_instance_of(Faraday::Connection).
            to receive(:get).
                with(URI, hash_including("fields[article]" => "title,pagecount"), Hash).
                and_return(double(Faraday::Response, :body => ARTICLE))
        end

        context "as Hash elements for each type" do
          context "where the values are Strings" do
            it "should pass them unchanged" do
              Subjoin::get(URI("http://example.com/articles"),
                           {
                             "include" => ["author", "comments"],
                             "fields[article]" => "title,pagecount"
                           })
            end
          end

          context "where the values are Arrays" do
            it "should join them into a string" do
              Subjoin::get(URI("http://example.com/articles"),
                           {
                             "include" => ["author", "comments"],
                             "fields[article]" => ["title", "pagecount"]
                           })
            end
          end
        end

        context "as a Hash for the whole" do
          it "should turn the keys and values into strings" do
              Subjoin::get(URI("http://example.com/articles"),
                           {
                             "include" => ["author", "comments"],
                             "fields" => {"article" => "title,pagecount"}
                           })
          end

          context "with the individual fields as Arrays of Strings" do
            it "should join those values into Strings" do
              Subjoin::get(URI("http://example.com/articles"),
                           {
                             "include" => ["author", "comments"],
                             "fields" => {"article" => ["title", "pagecount"]}
                           })
            end
          end
        end
      end
    end
  end
end
