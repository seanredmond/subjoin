module Subjoin
  class Relationship
    include Linkable
    include Metable

    attr_reader :links, :linkages
    def initialize(data)
      load_links(data['links'])
      @linkages = load_linkages(data['data'])
      load_meta(data['meta'])
    end

    private
    def load_linkages(data)
      return [] if data.nil?
      return [Identifier.new(data['type'], data['id'], data['meta'])] if data.is_a? Hash
      data.map{|l| Identifier.new(l['type'], l['id'], l['meta'])}
    end

  end
end
