module Subjoin
  # Container for related resources included in a compounf
  # document. Alllows Hash-like access by {Identifier}, type/id pair,
  # or Array-like access bu index
  class Inclusions
    def initialize(data)
      @inc = data
    end

    # @return [Array<Subjoin::Resource>] all included resources
    def all
      @inc
    end

    # @return [Subjoin::Resource] first included resource
    def first
      @inc.first
    end

    # Access a particular resource by id
    # @param id Either a {Subjoin::Identifier}, an Array of two strings
    #   taken as a type and an id, or an integer
    # @return [Subjoin::Resource]
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
