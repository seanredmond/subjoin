module Subjoin
  # A links object, i.e. a container for a number of link objects
  #
  # Example:
  #
  #     "links": {
  #         "self": "http://example.com/posts",
  #         "related": {
  #             "href": "http://example.com/articles/1/comments",
  #             "meta": {
  #                 "count": 10
  #             }
  #         }
  #     }
  #
  class Links
    # The array of {Link} objects
    # @return [Array]
    attr_reader :links
    def initialize(data)
      @links = load_links(data)
    end

    # Return the keys of all the contained links
    # @return [Array]
    def keys
      @links.keys
    end

    # Get a {Link} by key
    # @return [Link]
    def [](k)
      @links[k]
    end
    
    private
    def load_links(data)
      return {} if data.nil?
      Hash[data.map{|k, v| [k, Link.new(v)]}]
    end
  end
end
