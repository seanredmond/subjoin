module Subjoin
  class Key
    attr_reader :type
    attr_reader :id

    def initialize(type, id)
      @type = type
      @id = id
    end

    def ==(other)
      @type == other.type && @id == other.id
    end
  end
end
    
