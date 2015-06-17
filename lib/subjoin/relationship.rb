module Subjoin
  # A related resource link, providing access to resource objects
  # linked in a relationship
  # @see http://jsonapi.org/format/#document-resource-object-related-resource-links
  class Relationship
    include Linkable
    include Metable

    attr_reader :links, :linkages
    def initialize(data, doc)
      @document = doc
      @links = load_links(data['links'])
      @linkages = load_linkages(data['data'], doc)
      @meta = load_meta(data['meta'])
    end

    # Resolve available linkages and return related resources
    # @return [Array<Subjoin::Resource>]
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
