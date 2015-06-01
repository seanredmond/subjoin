module Subjoin
  # Generically construct and handle {Links} objects
  module Linkable
    attr_reader :links
    
    # Load the object's links
    # @param data [Hash] The object's parsed JSON `links` member
    def load_links(data)
      if data.nil?
        @links = nil if data.nil?
      else
        @links = Links.new(data)
      end
    end
  end
end
