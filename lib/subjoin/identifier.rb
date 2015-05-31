module Subjoin
  class Identifier
    include Keyable
    include Metable
    def initialize(data)
      load_key(data)
      load_meta(data['meta'])
    end
  end
end
