module Subjoin
  class Error < StandardError; end

  class NoOverriddenRootError < Error
    def message
      "You must derive a class from Subjoin::Resource and override Resource#Root to return the root URL of the API you are using. This derived class should, in turn be used as the base class for your other custom classes."
    end
  end

  class ResponseError < Error; end

  class UnexpectedTypeError < Error; end

  class SubclassError < Error; end
end
