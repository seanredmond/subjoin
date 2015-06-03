module Subjoin
  class Relationship
    include Linkable
    include Metable

    attr_reader :links, :linkages
    def initialize(data, doc)
      @document = doc
      load_links(data['links'])
      @linkages = load_linkages(data['data'], doc)
      load_meta(data['meta'])
    end

    def lookup
      return [] unless @document.has_included?
      @linkages.map{|l| @document.included[l]}
    end

    private
    def load_linkages(data, doc)
      return [] if data.nil?
      return [Identifier.new(data['type'], data['id'], data['meta'])] if data.is_a? Hash
      data.map{|l| Identifier.new(l['type'], l['id'], l['meta'])}
    end

  end
end
