module Subjoin
  class Identifier
    include Keyable
    def initialize(data)
      load_key(data)
    end
  end
end
