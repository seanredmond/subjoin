require "faraday"
require "json"
require "subjoin/attributable"
require "subjoin/errors"
require "subjoin/meta"
require "subjoin/metable"
require "subjoin/jsonapi"
require "subjoin/link"
require "subjoin/linkable"
require "subjoin/resource"
require "subjoin/identifier"
require "subjoin/inclusions"
require "subjoin/inheritableresource"
require "subjoin/relationship"
require "subjoin/document"
require "subjoin/version"

# TODO: recognize URI parameters: include, fields[], sort, page, filter

module Subjoin

  # Connection used for all HTTP resquests
  @@conn = Faraday.new

  private
  # Fetch and parse data from a URI
  # @param [URI] uri The endpoint to get
  # @return [Hash] Parsed JSON data
  # @raise [ResponseError] if the endpoint returns an error response
  def self.get(uri, params={})
    params = {} if params.nil?
    uri_params = uri.query.nil? ? {} : param_flatten(CGI::parse(uri.query))
    final_params = uri_params.merge(stringify_params(params))
    response = @@conn.get(uri, final_params)
    data = JSON.parse response.body

    if data.has_key?("errors")
      raise ResponseError.new
    end

    return data
  end

  # CGI::parse creates a hash whose values are arrays which is
  # incompatible with Faraday.get, so flatten the values
  def self.param_flatten(p)
    Hash[p.map{|k,v| [k, v.join(',')]}]
  end

  # If param value is an Array, join elements into a string
  # @param p [Hash] parameters
  # @return [Hash] with arrays joined into strings
  def self.stringify_params(p)
    Hash[p.map{|k, v| [k, v.is_a?(Array) ? v.join(",") : v]}]
  end
end
