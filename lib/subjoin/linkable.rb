module Subjoin
  module Linkable
    @links = nil

    def links
      @links ||= {}
    end
      
    def load_links(data)
      @links = Links.new(data)
    end
  end
end
