require "faraday"
require "json"
require "subjoin/errors"
require "subjoin/key"
require "subjoin/keyable"
require "subjoin/link"
require "subjoin/links"
require "subjoin/linkable"
require "subjoin/resource"
require "subjoin/identifier"
require "subjoin/relationship"
require "subjoin/version"

module Subjoin
  # Your code goes here...
  @@conn = Faraday.new

  def self.resources(uri)
    data = self.get uri
    return data
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
