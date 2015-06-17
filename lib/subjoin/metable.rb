module Subjoin
  # Generically handle meta objects
  module Metable

    # The object's meta attribute
    # @return [Meta]
    attr_reader :meta

    # Load the object's attributes
    # @param data [Hash] The object's parsed JSON `meta` member
    # @return [Metable,nil]
    def load_meta(data)
      return nil if data.nil?
      Meta.new(data)
    end

    def has_meta?
      return ! @meta.nil?
    end
  end
end
