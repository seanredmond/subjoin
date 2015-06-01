require "faraday"
require "json"
require "subjoin/attributable"
require "subjoin/errors"
require "subjoin/meta"
require "subjoin/metable"
require "subjoin/jsonapi"
require "subjoin/link"
require "subjoin/links"
require "subjoin/linkable"
require "subjoin/resource"
require "subjoin/identifier"
require "subjoin/relationship"
require "subjoin/document"
require "subjoin/version"

module Subjoin

  # Connection used for all HTTP resquests
  @@conn = Faraday.new

  # Get a document
  # @param uri [URI] The endpoint to get
  # @return [Document] 
  # @raise [ResponseError] if the endpoint returns an error response
  def self.document(uri)
    data = self.get uri
    return Document.new(data)
  end

  private
  # Fetch and parse data from a URI
  # @param [URI] uri The endpoint to get
  # @returns [Hash] Parsed JSON data
  # @raise [ResponseError] if the endpoint returns an error response
  def self.get(uri)
    response = @@conn.get(uri)
    data = JSON.parse response.body

    if data.has_key?("errors")
      raise ResponseError.new
    end

    return data
  end
end
