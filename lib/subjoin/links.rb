module Subjoin
  class Links
    attr_reader :links
    def initialize(data)
      @links = load_links(data)
    end

    def keys
      @links.keys
    end

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
