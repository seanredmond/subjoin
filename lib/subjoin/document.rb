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
      if args.count == 1
        spec = args[0]
        if spec.is_a?(URI)
          contents = Subjoin::get(spec)
        elsif spec.is_a?(Hash)
          contents = spec
        elsif spec.is_a?(String)
          contents = Subjoin::get(mapped_type(spec))
        end
      elsif args.count == 2
        type, id = args
        contents = Subjoin::get(URI([mapped_type(type), id].join('/')))
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
      
      if contents.has_key?("data")
        if contents["data"].is_a? Hash
          @data = [Resource.new(contents["data"], self)]
        else
          @data = contents["data"].map{|d| Resource.new(d, self)}
        end
      else
        @data = nil
      end

      if contents.has_key?("jsonapi")
        @jsonapi = JsonApi.new(contents["jsonapi"])
      else
        @jsonapi = nil
      end
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
                select{|c| c.is_a?(Class) and c < Subjoin::DerivableResource}
      Hash[d_types.map{|c| [c::type_id, c]}]
    end
  end
end
                   

      
      
