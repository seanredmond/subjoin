module Subjoin
  # Generically construct and handle {Links} objects
  module Linkable
    attr_reader :links
    
    # Load the object's links
    # @param data [Hash] The object's parsed JSON `links` member
    # @return [Hash]
    def load_links(data)
      return nil if data.nil?
      Hash[data.map{|k, v| [k, Link.new(v)]}]
    end

    def has_links?
      return ! @links.nil?
    end
  end
end
