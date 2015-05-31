module Subjoin
  class Resource
    include Keyable
    include Attributable

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
      @links = load_objects(data['links'], Link)
      @relationships = load_objects(data['relationships'], Relationship)
    end

    def links(spec = nil)
      return @links if spec.nil?
      @links[spec]
    end

    private
    def load_objects(data, type)
      return {} if data.nil?

      Hash[data.map{|k, v| [k, type.new(v)]}]
    end
  end
end

