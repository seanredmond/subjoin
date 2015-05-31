module Subjoin
  # Generically construct and handle {Links} objects
  module Linkable
    @links = nil

    def links
      @links ||= {}
    end

    # Load the object's links
    # @param data [Hash] The object's parsed JSON `links` member
    def load_links(data)
      @links = Links.new(data)
    end
  end
end
