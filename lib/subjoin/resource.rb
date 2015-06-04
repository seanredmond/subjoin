module Subjoin
  class Resource
    include Attributable
    #include Keyable
    include Linkable

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

      #load_key(data)

      @identifier = Identifier.new(data['type'], data['id'])
      
      load_attributes(data['attributes'])
      load_links(data['links'])
      @relationships = load_relationships(data['relationships'], @document)
    end

    def type
      @identifier.type
    end

    def id
      @identifier.id
    end
    
    private
    def load_relationships(data, doc)
      return {} if data.nil?

      Hash[data.map{|k, v| [k, Relationship.new(v, doc)]}]
    end
  end
end

