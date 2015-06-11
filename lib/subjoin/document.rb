module Subjoin
  # A JSON-API top level document
  class Document
    include Metable
    include Linkable

    # The document's primary data
    attr_reader :data

    # Resources included in a compound document"
    attr_reader :included

    # JSON-API version information
    attr_reader :jsonapi


    # Create a document. Parameters can take several forms:
    # 1. A {URI} object: Document will be created from the URI
    # 2. A {Hash}: The Hash is assumed to be a parsed JSON response and the
    #    Document will be created from that
    # 3. One string: Assumed to be a JSON-API object type. An attempt will be
    #    made to map this type to a class that inherits from
    #    {DerivableResource} and to load the create the Document from a URL
    #    provided by that class. There is also the assumption that this URL
    #    returns all objects of that type.
    # 4. Two strings: Assumed to be a JSON-API object type and id. The same
    #    mapping is attempted as before, and the second parameter is added to
    #    the URL
    # @param [Array] args
    def initialize(*args)
      if args.count < 1
        raise ArgumentError.new
      end

      if args[0].is_a?(URI)
        contents = Subjoin::get(args[0], args[1])
      elsif args[0].is_a?(Hash)
          contents = args[0]
      elsif args[0].is_a?(String)
        type, id = args
        if id.nil?
          contents = Subjoin::get(mapped_type(args[0]))
        else
          contents = Subjoin::get(URI([mapped_type(type), id].join('/')))
        end
      else
        raise ArgumentError
      end

      load_meta(contents['meta'])
      load_links(contents['links'])

      if contents.has_key? "included"
        @included = Inclusions.new(
          contents['included'].map{|o| Resource.new(o, self)}
        )
      else
        @included = nil
      end

      @data = load_data(contents)
      @jsonapi = load_jsonapi(contents)
    end

    # @return [Boolean] true if there is primary data
    def has_data?
      return ! @data.nil?
    end

    # @return [Boolean] true if there are included resources
    def has_included?
      return ! @included.nil?
    end

    # @return [Boolean] true if there is version information
    def has_jsonapi?
      return ! @jsonapi.nil?
    end

    private

    # Take the data element and make an Array of instantiated Resource
    # objects. Turn single objects into a single item Array to be consistent.
    # @param c [Hash] Parsed JSON
    # @return [Array, nil]
    def load_data(c)
      return nil unless c.has_key?("data")

      #single resource, but instantiate it and stick it in an Array
      return [Resource.new(c["data"], self)] if c["data"].is_a? Hash

      # Instantiate Resources for each array element
      return c["data"].map{|d| Resource.new(d, self)}
    end

    # Load jsonapi property if present
    # @param c [Hash] Parsed JSON
    # @return [Subjoin::JsonApi, nil]
    def load_jsonapi(c)
      return nil unless c.has_key?("jsonapi")
      @jsonapi = JsonApi.new(c["jsonapi"])
    end

    def mapped_type(t)
      d_type = type_map.fetch(t, nil)
      if d_type.nil?
        throw ArgumentError
      end
      return d_type::type_url
    end
      
    def type_map
      @type_map ||= create_type_map
    end
    
    def create_type_map
      d_types = Subjoin.constants.
                map{|c| Subjoin.const_get(c)}.
                select{|c| c.is_a?(Class) and c < Subjoin::InheritableResource}
      Hash[d_types.map{|c| [c::type_id, c]}]
    end
  end
end
                   

      
      
