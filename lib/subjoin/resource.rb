module Subjoin
  class Resource
    include Attributable
    include Keyable
    include Linkable

    attr_reader :relationships
    
    def initialize(spec)
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

      load_key(data)
      load_attributes(data['attributes'])
      load_links(data['links'])
      @relationships = load_relationships(data['relationships'])
    end

    private
    def load_relationships(data)
      return {} if data.nil?

      Hash[data.map{|k, v| [k, Relationship.new(v)]}]
    end
  end
end

