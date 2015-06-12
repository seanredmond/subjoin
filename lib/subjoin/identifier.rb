module Subjoin
  class Identifier
#    include Keyable
    include Metable

    attr_reader :type
    attr_reader :id
    
    def initialize(type, id, meta=nil)
      #load_key(data)
      @type = type
      @id = id
      @meta = load_meta(meta)
    end

    def ==(other)
      return @type == other.type && @id == other.id
    end
  end
end
