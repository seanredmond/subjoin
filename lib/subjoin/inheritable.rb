# coding: utf-8
module Subjoin
  # Mixin providing methods necessary for using custom classes derived
  # from {Resource}.
  #
  # Using this approach you create your own classes to represent
  # JSON-API resource types of a specific JSON-API server
  # implementation. These classes must be sub-classes of {Resource}
  # and must include {Inheritable}. Next you must override a class
  # variable, `ROOT_URI`, which should be the root of all URIs of the
  # API.
  #
  # By default, Subjoin will use the lower-cased name of the class as
  # the type in URIs. If the class name does not match the type, you
  # can further override `TYPE_PATH` to indicate the name (or longer URI
  # fragment) that should be used in URIs to request the resource
  # type. Your custom classes must also be part of the Subjoin
  # module. You should probably create one sub-class of
  # Subjoin::Resource that overrides `ROOT_URI`, and then create other
  # classes as sub-classes of this:
  #
  #    module Subjoin
  #      # Use this class as the parent of further subclasses.
  #      # They will inherit the ROOT_URI defined here
  #      class ExampleResource < Subjoin::Resource
  #        include Inheritable
  #        ROOT_URI="http://example.com"
  #      end
  #
  #      # Subjoin will make requests to http://example.com/articles
  #      class Articles < ExampleResource
  #      end
  #
  #      # Use TYPE_PATH if you don't want to name the class the same thing as
  #      # the type
  #      class ArticleComments < ExampleResource
  #        TYPE_PATH="comments"
  #      end
  #    end
  module Inheritable
    # Root URI for all API requests
    ROOT_URI = nil

    # JSON-API type corresponding to this class, and presumably string
    # to be used in requests for resources of this type. If not
    # provided, the lower-cased name of the class will be used
    TYPE_PATH = nil

    # Callback invoked whenever module is included in another module
    # or class.
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Class methods for objects that include this mixin
    module ClassMethods
      # @return [String] JSON-API type corresponding to this
      # class. Lower-cased name of the class unless TYPE_PATH is
      # specified
      def type_id
        return self.to_s.downcase.gsub(/^.*::/, '') if self::TYPE_PATH.nil?
        return self::TYPE_PATH
      end
    
      # @return [URI] URI for requesting an object of this type, based
      # of ROOT_URI and {#type_id}
      def type_url
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
end
