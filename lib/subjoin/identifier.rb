module Subjoin
  class Identifier
    def initialize(data)
      @type = data['type']
      @id = data['id']
    end
  end
end
