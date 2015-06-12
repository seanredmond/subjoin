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
    # 1. A URI object: Document will be created from the URI
    # 2. A Hash: The Hash is assumed to be a parsed JSON response and the
    #    Document will be created from that
    # 3. One string: Assumed to be a JSON-API object type. An attempt will be
    #    made to map this type to a class that inherits from
    #    {InheritableResource} and to load the create the Document from a URL
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

      contents = load_by_type(args[0], args[1..-1])

      @meta = load_meta(contents['meta'])
      @links = load_links(contents['links'])
      @included = load_included(contents)
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

    def load_by_type(firstArg, restArgs)
      # We were passed a URI. Load it
      return Subjoin::get(firstArg, restArgs[0]) if firstArg.is_a?(URI)

      # We were passed a Hash. Just use it
      return firstArg if firstArg.is_a?(Hash)

      # We were passed a type, and maybe an id.
      return load_by_id(firstArg, restArgs) if firstArg.is_a?(String)

      # None of the above
      raise ArgumentError.new
    end

    def load_by_id(firstArg, restArgs)
      type = firstArg
      id = restArgs.first

      return Subjoin::get(mapped_type(type)) if id.nil?

      Subjoin::get(URI([mapped_type(type), id].join('/')))
    end
      
    
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

    # Instantiate a {Subjoin::Inclusions object if the included property is
    # present
    # @param c [Hash] Parsed JSON
    # @return [Subjoin::Inclusions, nil]
    def load_included(c)
      return nil unless c.has_key? "included"

      Inclusions.new(c['included'].map{|o| Resource.new(o, self)})
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
                   

      
      
