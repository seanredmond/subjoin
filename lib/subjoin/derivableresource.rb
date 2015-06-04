module Subjoin
  class DerivableResource < Resource
    ROOT_URI = nil
    TYPE_PATH = nil

    def self.type_url
      if self.class == Resource
        raise Subjoin::SubclassError.new "Class must be a subclass of Resource to use this method"
      end

      if self::ROOT_URI.nil?
        raise Subjoin::SubclassError.new "#{self.class} or a parent of #{self.class} derived from Subjoin::Resource must override ROOT_URI to use this method"
      end

      if self::TYPE_PATH.nil?
        type_segment = self.to_s.downcase.gsub(/^.*::/, '')
      else
        type_segment = self::TYPE_PATH
      end

      return [self::ROOT_URI, type_segment].join('/')
    end
  end
end
