module Subjoin
  # Meta object
  # @see http://jsonapi.org/format/#document-meta
  class Meta
    include Attributable
    def initialize(data)
      load_attributes(data)
    end
  end
end
