module Subjoin
  # A resource identifier object
  # @see http://jsonapi.org/format/#document-resource-identifier-objects
  class Identifier
    include Metable

    attr_reader :type
    attr_reader :id
    
    def initialize(type, id, meta=nil)
      #load_key(data)
      @type = type
      @id = id
      @meta = load_meta(meta)
    end

    # Test for equality. Two Ideintifers are considered equal if they
    # have the same type and id
    def ==(other)
      return @type == other.type && @id == other.id
    end
  end
end
