module Subjoin
  # Generically handle arbitrary object attributes
  module Attributable

    # The object's attributes
    # @return [Hash]
    attr_reader :attributes

    # Load the object's attributes
    # @param data [Hash] The object's parsed JSON `attribute` member
    def load_attributes(data)
      @attributes = data
    end

    # Take any arbitrary name and look it up in the attributes Hash
    # @param name [String] attribute name to fetch
    # @return [Object] the attribute value
    # @raise [NoMethodError] if no such attribute exists
    def method_missing name, *args
      name = name.to_s
      if args.empty? && @attributes.keys.include?(name)
        return @attributes[name]
      end
      raise NoMethodError, "undefined method `#{name}' for #{self}"
    end
  end
end
