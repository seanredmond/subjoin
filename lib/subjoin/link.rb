module Subjoin
  class Link
    attr_accessor :href, :meta
    def initialize(data)
      if data.is_a? String
        @href = data
      else
        @href = data['href']
        @meta = data['meta']
      end
    end

    def has_meta?
      return ! @meta.nil?
    end

    def to_s
      @href
    end
  end
end
