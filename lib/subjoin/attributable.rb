module Subjoin
  module Attributable

    attr_reader :attributes

    def load_attributes(data)
      @attributes = data
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
