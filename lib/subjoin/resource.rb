module Subjoin
  class Resource

    @@conn = Faraday.new

    class << self
      def root
        raise NoOverriddenRootError.new
      end

      def classname
        self.name.to_s.downcase
      end

      def request_path
        [self.root, self.classname].join('/')
      end

      def all
        @@conn.get self.request_path
      end
    end

    def initialize(data)
      if data.is_a?(Hash)
        @data = data
      else
        response = get(data)
      end
    end

    def get(id)
      resp = @@conn.get [self.request_path, id].join('/')
    end
    
    def root
      return self.class.root
    end

    def classname
      return self.class.classname
    end

    def request_path
      self.class.request_path
    end
  end
end

