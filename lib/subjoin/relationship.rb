module Subjoin
  class Relationship
    include Linkable

    def initialize(data)
      @links = load_links(data['links'])
    end
  end
end
