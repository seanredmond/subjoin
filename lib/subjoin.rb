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
require "subjoin/inheritable"
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

  # If param value is an Array, join elements into a string. `field` parameters
  # passed as a Hash will be converted to key value pairs like
  # "field[type]"="fields1,field2"
  # @param p [Hash] parameters
  # @return [Hash] with arrays joined into strings
  def self.stringify_params(p)
    fieldify(Hash[p.map{|k, v| [k, stringify_value(v, k) ]}])
  end

  # Turn parameter values into Strings if they are Hashes or Arrays
  # @param v The value to check
  # @param k The key corresponding to the value passed in
  # @return [String,Hash] If a Hash is returned it will be taken care of by
  #   {fieldify}
  def self.stringify_value(v, k=nil)
    return v if v.is_a?(String)
    return v.join(",") if v.is_a?(Array)
    if v.is_a?(Hash)
      return Hash[v.map{|key, val| ["#{k}[#{key}]", stringify_value(val)]}]
    end
    raise ArgumentError.new
  end

  # If a field paramter has been passed as a Hash it will still be a Hash and
  # and we want to replace `field` with it's value
  # @param h [Hash]
  def self.fieldify(h)
    if h.has_key? "fields"
      f = h.delete("fields")
      return h.merge(f)
    end

    return h
  end
end
