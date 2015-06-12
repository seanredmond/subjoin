module Subjoin
  # Generically handle arbitrary object attributes
  # @see http://jsonapi.org/format/#document-resource-object-attributes
  module Attributable

    # The object's attributes
    # @return [Hash]
    attr_reader :attributes

    # Load the object's attributes
    # @param data [Hash] The object's parsed JSON `attribute` member
    def load_attributes(data)
      @attributes = data
    end


    # Access an attribute by property name
    # @param name [String] the property name
    # @return The property value, or nil if no such property exists
    def [](name)
      name = name.to_s
      if @attributes.has_key?(name)
        return @attributes[name]
      end
      return nil
    end
  end
end
