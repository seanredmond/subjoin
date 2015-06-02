module Subjoin
  class Inclusions
    def initialize(data)
      @inc = data
    end

    def all
      @inc
    end

    def first
      @inc.first
    end
    
    def [](id)
      if id.is_a?(Identifier)
        return @inc.select{|i| i.identifier == id}.first
      end

      if id.is_a?(Array) && id.count == 2
        idd = Identifier.new(id[0], id[1])
        return @inc.select{|i| i.identifier == idd}.first
      end

      if id.is_a?(Fixnum)
        return @inc[id]
      end
    end
  end
end
