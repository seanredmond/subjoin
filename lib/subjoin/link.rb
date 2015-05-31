module Subjoin
  # A link object
  class Link
    # The URL for this link
    # @return String
    attr_reader :href

    # Metadata object for this link
    attr_reader :meta
    def initialize(data)
      if data.is_a? String
        @href = data
      else
        @href = data['href']
        @meta = data['meta'].nil? ? nil : Subjoin::Meta.new(data['meta'])
      end
    end

    # @return True if the Link has a defined `meta` member
    def has_meta?
      return ! @meta.nil?
    end

    # Returns the {#href} attribute
    def to_s
      @href
    end
  end
end
