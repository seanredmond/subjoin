module Subjoin
  class Relationship
    include Linkable

    attr_reader :links
    def initialize(data)
      @links = load_links(data['links'])
    end
  end
end
