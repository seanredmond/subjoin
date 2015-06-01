module Subjoin
  # JSON-API version information
  class JsonApi
    include Metable
    attr_reader :version
    def initialize(data)
      @version = data['version']
      load_meta(data['version'])
    end
  end
end
      
    
