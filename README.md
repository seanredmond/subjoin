# Subjoin

A practical wrapper for [JSON-API](http://jsonapi.org) interactions.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'subjoin'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install subjoin

## Documentation

For full documentation run

    $ yardoc
    $ yard server

Then load http://localhost:8808 in your browser

## Usage

The simplest starting point to create a ```Subjoin::Document``` with a URI:

    require "subjoin"
    doc = Subjoin::Document.new(URI("http://example.com/articles"))

```Subjoin::document``` does not distinguish between simple and compound
documents. Rather, the returned ```Subjoin::Document``` may have ```data```,
```included```, ```links```, ```meta``` and/or ```jsonapi``` members based on
the response.

### Document

You can access all the expected members of the [top-level document](http://jsonapi.org/format/#document-top-level):

    doc = Subjoin::Document.new(URI("http://example.com/articles"))
	doc.data     # Array of Resource objects
	doc.links    # Links object
	doc.included # Inclusions object
	doc.meta     # Meta object
	doc.jsonapi  # JsonApi object

The ```#data``` attribute will always be an Array (or nil). If the document's
```data``` member is an object because the document contains only one resource
it will still be constructed as an ```Array``` (with one member) in the
```Document``` object.

There are, in addition, methods to test whether any of the above members are
present:

    doc.has_data?
	doc.has_links?
	doc.has_included?
	doc.has_meta?
	doc.has_jsonapi?

### Resources

A [Resource](http://jsonapi.org/format/#document-resource-objects) is a single JSON-API object. Given this JSON:

	{
	  "data": {
		"type": "articles",
		"id": "1",
		"attributes": {
		  "title": "JSON API paints my bikeshed!"
		},
		"links": {
		  "self": "http://example.com/articles/1"
		},
		"relationships": {
		  "author": {
			"links": {
			  "self": "http://example.com/articles/1/relationships/author",
			  "related": "http://example.com/articles/1/author"
			},
			"data": { "type": "people", "id": "9" }
		  },
		  "comments": {
			"links": {
			  "self": "http://example.com/articles/1/relationships/comments",
			  "related": "http://example.com/articles/1/comments"
			},
			"data": [
			  { "type": "comments", "id": "5" },
			  { "type": "comments", "id": "12" }
			]
		  }
		}
	  }
	}

The equivalent ```Subjoin::Resource``` object has a number of methods for
accessing the data.

    doc = Subjoin::Document.new(URI("http://example.com/articles/1"))
	article = doc.data.first             # the Resource
    article.type                         # "articles"
    article.id                           # "1"
	article.links                        # A Subjoin::Links object
	article.links["self"].href           # "http://example.com/articles/1"
    article.relationships                # A Hash of Subjoin::Relationship objects

Attributes are accessible directly through like Hash keys or through the
```attributes``` Hash

    article["title"]               # Both return 
    article.attributes["title"] # "JSON API paints my bikeshed!"

### Resource Identifiers

[Resource identifiers](http://jsonapi.org/format/#document-resource-identifier-objects)
occur in Relationship objects as pointers to other resources by ```type``` and
```id``` (they may have, optionally, a ```meta``` attribute as well). Subjoin
also constructs an Identifier object out of the ```type``` and ```id```
attributes of a Resource (always without the ```meta```).

    article.identifier      # Identifier.object
    article.identifier.type # "articles"
	article.identifier.id   # "1"
    article.type            # "articles", from the Identifier object
	article.id              # "1" from the Identifier object

Two Identifier objects are considered to be equal (==) if both their `type` and
`id` match. The ```meta``` attribute is ignored in tests for equality.

### Relationships

Resources may have [relationsips](http://jsonapi.org/format/#document-resource-object-relationships) to other resources.


    article.relationships                    # A Hash of
                                             # Subjoin::Relationship objects
    article.relationships.keys               # ["author", "comments"]
	article.relationships["author"]          # Subjoin::Links object
	article.relationships["author"].links    # Array of Subjoin::Link objects
	article.relationships["author"].type     # "people"
	article.relationships["author"].linkages # Array of Identifiers

The related resources can be loaded from their links:

    article.relationships["author"].links.links["self"].get

Or, in a compound document, the ```Identifiers``` in the ```linkages``` array can be used to look up included resources:

	identifier = article.relationships.linkages.first
    document.included[identifier] # Returns the related resource

### Links

```links``` attributes are instantiated as Subjoin::Links objects, accessible through a ```#links``` method on any object that can have links. ```Links``` abjects contain ```Subjoin::Link``` objects, which are accessed by key.

JSON-API allows for two formats: one simply with a link

    "links": {
      "self": "http://example.com/posts"
    }

and one with an ```href``` attribute and ```meta``` object:

	"links": {
	  "related": {
		"href": "http://example.com/articles/1/comments",
		"meta": {
		  "count": 10
		}
	  }
	}

```Subjoin::Link``` objects treat either variation like the latter.

    # Instantiated from the more complete format:
    article.links["related"].href       # "http://example.com/articles/1/comments"
    article.links["related"].has_meta?  # true
    article.links["related"].meta.count # 10

    # Instantiated from the simpler format:
    article.links["self"].href          # "http://example.com/posts"
    article.links["related"].has_meta?  # false
    article.links["related"].meta       # nil

If you have a ```Link``` you can get a new ```Document```

    article.links["related"].get # Same thing as Subjoin::Document.new
                                 # with the URL

### Included Resources

Included resources are gathered into a ```Subjoin::Inclusions``` object, and can be accessed in several ways. In the jsonapi.org [compund document example](http://jsonapi.org/format/#document-compound-documents), the ```article``` has a ```relationship``` to an ```author``` with the type and id (```linkage```) of "person" and "9". In a Subjoin ```Document```, the included ```Resource``` can be fetched via the ```Identifer``` from the ```linkages``` of a
```Relationship```:

    doc = Subjoin::Document.new(""http://example.com/articles/1")
	article = doc.data.first
	authrel = article.relationships["author"].linkages.first # Identifier
	auth = doc.included[authrel]                             # Resource 

By an array containing a type and an id:

    auth = doc.included[["people", "9"]]

By index

    auth = doc.included[0]

All these methods return ```nil``` if there is so matching
resource. There also a couple of convenience methods:

    doc.included.all   # Get the full array of included resources
    doc.included.first # Get the first included resource

### Meta Information

[Meta information](http://jsonapi.org/format/#document-meta) is represented by
```Subjoin::Meta``` objects. Any object that might have meta information will
have a ```#meta``` attribute. ```Meta``` object attributes are accessible by
name like other attributes.

Given this JSON:

    {
	  "meta": {
		"copyright": "Copyright 2015 Example Corp.",
		"authors": [
		  "Yehuda Katz",
		  "Steve Klabnik",
		  "Dan Gebhardt",
		  "Tyler Kellen"
		]
	  },
	  "data": {
		// ...
	  }
	}

The data might be accessed in this way:

    article.meta           # Meta object
    article.meta.copyright # "Copyright 2015 Example Corp."

## Why is it called "Subjoin"

Nice word. Sounds coder-y. Has most of the letters of "Ruby JSON-API".

## Contributing

1. Fork it ( https://github.com/[my-github-username]/subjoin/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
