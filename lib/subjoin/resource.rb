module Subjoin
  class Resource
    attr_accessor :id, :type
    @@conn = Faraday.new

    class << self
    def resources(uri)
      data = self.get uri
      return data
    end
    
    def get(uri)
      
      response = @@conn.get(uri)
      data = JSON.parse response.body

      if data.has_key?("errors")
        raise ResponseError.new
      end

      return data
    end
    end
    
    def initialize(spec)
      if spec.is_a?(URI)
        @data = self.class.get(spec)
      end
    end
        
    def method_missing name, *args
      name = name.to_s
      if args.empty? && @attributes.keys.include?(name)
        return @attributes[name]
      end
      raise NoMethodError, "undefined method `#{name}' for #{self}"
    end    
  end
end

