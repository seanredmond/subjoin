require "faraday"
require "json"
require "subjoin/errors"
require "subjoin/link"
require "subjoin/resource"
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
