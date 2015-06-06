module Subjoin
  class InheritableResource < Resource
    ROOT_URI = nil
    TYPE_PATH = nil


    def self.type_id
      return self.to_s.downcase.gsub(/^.*::/, '') if self::TYPE_PATH.nil?
      return self::TYPE_PATH
    end
    
    def self.type_url
      if self.class == Resource
        raise Subjoin::SubclassError.new "Class must be a subclass of Resource to use this method"
      end

      if self::ROOT_URI.nil?
        raise Subjoin::SubclassError.new "#{self.class} or a parent of #{self.class} derived from Subjoin::Resource must override ROOT_URI to use this method"
      end


      return URI([self::ROOT_URI, self::type_id].join('/'))
    end
  end
end
