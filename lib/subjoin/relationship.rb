module Subjoin
  class Relationship
    include Linkable

    attr_reader :links, :linkages
    def initialize(data)
      @links = load_links(data['links'])
      @linkages = load_linkages(data['data'])
    end

    private
    def load_linkages(data)
      return [] if data.nil?
      return [Identifier.new(data)] if data.is_a? Hash
      data.map{|l| Identifier.new(l)}
    end

  end
end
