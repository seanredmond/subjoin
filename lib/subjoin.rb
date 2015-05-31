require "faraday"
require "json"
require "subjoin/attributable"
require "subjoin/errors"
require "subjoin/key"
require "subjoin/keyable"
require "subjoin/link"
require "subjoin/links"
require "subjoin/linkable"
require "subjoin/meta"
require "subjoin/resource"
require "subjoin/identifier"
require "subjoin/relationship"
require "subjoin/compound_document"
require "subjoin/version"

module Subjoin
  # Your code goes here...
  @@conn = Faraday.new

  def self.resources(uri)
    data = self.get uri

    # If there is a data element and that data element is a Hash then we have a
    # single object response
    if data.has_key?("data") && data['data'].is_a?(Hash)
      return Resource.new(data)
    end

    # Otherwise we have a compound document with many objects, or the response
    # only contains mets, links, etc. which we can still treat as a compound
    # document
    return CompoundDocument.new(data)
  end
    
  def self.get(uri)
    response = @@conn.get(uri)
    data = JSON.parse response.body

    if data.has_key?("errors")
      raise ResponseError.new
    end

    return data
  end
end
