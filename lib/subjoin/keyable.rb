module Subjoin
  # Generically handle construction of and access to object {Keys}
  module Keyable

    # The object's {Key} constructed from `type` and `id` attributes
    # @return [Key] 
    attr_reader :key

    # Load the object's key
    # @param data [Hash] Parsed JSON data. The Hash should contain `type` and
    #   `id` attributes
    def load_key(data)
      @key = Key.new(data['type'], data['id'])
    end

    # @return [String] the {Key}'s type
    def type
      @key.type
    end

    # @return [String,Object] the {Key}'s id. Probably a String
    def id
      @key.id
    end
  end
end

