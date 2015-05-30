module Subjoin
  module Keyable
    attr_reader :key

    def load_key(data)
      @key = Key.new(data['type'], data['id'])
    end

    def type
      @key.type
    end

    def id
      @key.id
    end
  end
end

