module Subjoin
  class CompoundDocument

    attr_reader :resources
    attr_reader :included
    attr_reader :meta
    
    def initialize(spec)
      if spec.is_a?(URI)
        data = Subjoin::get(spec)
      elsif spec.is_a?(Hash)
        data = spec
      end

      if data['data'].is_a?(Hash)
        raise UnexpectedTypeError.new
      end

      @resources = data['data'].map{|o| Resource.new(o)}
      @included = data['included'].map{|o| Resource.new(o)}
      @meta = data['meta'].nil? ? nil : Subjoin::Meta.new(data['meta'])
    end
  end
end
