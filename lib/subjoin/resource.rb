module Subjoin
  class Resource
    attr_accessor :id, :type

    def initialize(spec)
      if spec.is_a?(URI)
        data = Subjoin::get(spec)
      elsif spec.is_a?(Hash)
        data = spec
      end

      if data['data'].is_a?(Array)
        raise UnexpectedTypeError.new
      end

      @id = data['data']['id']
      @type = data['data']['type']
      @attributes = data['data']['attributes']
      @links = load_objects(data['data']['links'], Link)
      @relationships = load_objects(data['data']['relationships'], Relationship)
    end

    def links(spec = nil)
      return @links if spec.nil?
      @links[spec]
    end
        
    def method_missing name, *args
      name = name.to_s
      if args.empty? && @attributes.keys.include?(name)
        return @attributes[name]
      end
      raise NoMethodError, "undefined method `#{name}' for #{self}"
    end

    private
    def load_objects(data, type)
      return {} if data.nil?

      Hash[data.map{|k, v| [k, type.new(v)]}]
    end
  end
end

