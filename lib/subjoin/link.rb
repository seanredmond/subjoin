module Subjoin
  # A link object
  class Link
    include Metable

    # The URL for this link
    # @return String
    attr_reader :href

    def initialize(data)
      if data.is_a? String
        @href = data
      else
        @href = data['href']
        load_meta(data['meta'])
      end
    end

    # Returns the {#href} attribute
    def to_s
      @href
    end
  end
end
