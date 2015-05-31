module Subjoin
  # Treats {#type} and {#id} as a composite key
  class Key
    # The type attribute
    attr_reader :type

    # The id attribute
    attr_reader :id

    # @param [String] type The object type
    # @param id The object id
    def initialize(type, id)
      @type = type
      @id = id
    end

    # True if {#type} and {#id} are both equal
    # @param [Key] other The Key to compare
    # @return [Boolean]
    def ==(other)
      @type == other.type && @id == other.id
    end
  end
end
    
