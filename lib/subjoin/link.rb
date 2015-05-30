module Subjoin
  # A link object
  class Link
    # The URL for this link
    # @return String
    attr_accessor :href

    # Metadata object for thi link
    attr_accessor :meta
    def initialize(data)
      if data.is_a? String
        @href = data
      else
        @href = data['href']
        @meta = data['meta']
      end
    end

    # @return True if the Link has a defined `meta` member
    def has_meta?
      return ! @meta.nil?
    end

    # Returns the #href attribute
    def to_s
      @href
    end
  end
end
