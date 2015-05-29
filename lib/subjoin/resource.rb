module Subjoin
  class Resource
    attr_accessor :id, :type

    def initialize(spec)
      if spec.is_a?(URI)
        data = Subjoin::get(spec)

        if data['data'].is_a?(Array)
          raise UnexpectedTypeError.new
        end
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

