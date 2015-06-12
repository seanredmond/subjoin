module Subjoin
  class Resource
    include Attributable
    #include Keyable
    include Linkable
    include Metable

    # The relationships specified for the object
    # @return [Hash<Relationship>]
    attr_reader :relationships

    attr_reader :identifier
    
    def initialize(spec, doc = nil)
      @document = doc
      if spec.is_a?(URI)
        data = Subjoin::get(spec)
      elsif spec.is_a?(Hash)
        data = spec
      end

      if data.has_key?("data")
        data = data["data"]
      end

      if data.is_a?(Array)
        raise UnexpectedTypeError.new
      end

      @identifier = Identifier.new(data['type'], data['id'])
      
      load_attributes(data['attributes'])
      @links = load_links(data['links'])
      @relationships = load_relationships(data['relationships'], @document)
      @meta = load_meta(data['meta'])
    end

    def type
      @identifier.type
    end

    def id
      @identifier.id
    end

    # Get a related resource or resources. This method resolves the
    # relationship linkages and fetches the included {Subjoin::Resource}
    # objects themselves.
    # @param spec [String] key for the desired resource
    # @param doc [Subjoin::Document] Document in which to look for related
    #   resources. By default it is the same document from which the resource
    #   came itself.
    # @return [Hash, Array<Subjoin:Resource>, nil] If called with a spec
    # parameter, the return value will be an Array of {Subjoin::Resource}
    # objects corresponding to the key, or nil if that key doesn't exist. If
    # called without a spec parameter, the return value will be a Hash whose
    # keys are the same as {Resource#relationships}, but whose values are
    # Arrays of resolved {Resource} objects. In practice this means that you
    # have a choice of idioms (method vs. hash) since
    #
    #    obj.rels("key")
    #
    # and
    #
    #    obj.rels["key"]
    #
    # are equivalent
    def rels(spec = nil, doc = @document)
      return nil if doc.nil?
      return nil unless doc.has_included?

      if spec.nil?
        return Hash[relationships.keys.map{|k| [k, rels(k, doc)]}]
      end
      
      relationships[spec].linkages.map{|l| doc.included[l]}
    end
    
    private
    def load_relationships(data, doc)
      return {} if data.nil?

      Hash[data.map{|k, v| [k, Relationship.new(v, doc)]}]
    end
  end
end

