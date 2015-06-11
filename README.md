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

Resources may have
[relationships](http://jsonapi.org/format/#document-resource-object-relationships)
to other resources. There are two methods to access these:
{Subjoin::Resource#relationships} which returns
{Subjoin::Relationship} objects and {Subjoin::Resource#rels} which
resolves the relationship linkages and returns to related
{Subjoin::Resource} objects themselves. Using #relationships:


    article.relationships                    # A Hash of
                                             #   Subjoin::Relationship objects
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

It will almost always be simpler to use {Subjoin::Resource#rels}:

    article.rels                      # A Hash of Arrays of
                                      #   Subjoin::Resource objects
    article.rels.keys                 # ["author", "comments"]
    article.rels["author"].first      # Subjoin::Resource object. Remember,
                                      #   #rels always returns an Array
    article.rels("author").first      # Another way to say the same thing
    article.rels["author"].first.type # "people"

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

Included resources are gathered into a ```Subjoin::Inclusions```
object, and can be accessed in several ways. In the jsonapi.org
[compund document example](http://jsonapi.org/format/#document-compound-documents),
the ```article``` has a ```relationship``` to an ```author``` with the
type and id (```linkage```) of "person" and "9". In a Subjoin
```Document```, the included ```Resource``` can be fetched via the
```Identifer``` from the ```linkages``` of a ```Relationship```:

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

## Using Inheritance

Another way to use Subjoin is via inheritance. Using this approach you create
your own classes to represent JSON-API resource types of a specific JSON-API
server implementation. These classes must be sub-classes of
```Subjoin::InheritableResource``` and must override a class variable,
```ROOT_URI```, which should be the root of all URIs of the API. For instance,
in the examples above, "http://example.com" would be the value of
```ROOT_URI```. By default, Subjoin will use the lower-cased name of the class
as the type in URIs. If the class name does not match the type, you can further
override ```TYPE_PATH``` to indicate the name (or longer URI fragment) that
should be used in URIs to request the resource type.

Your custom classes must be part of the ```Subjoin``` module. You should
probably create one sub-class of ```Subjoin::InheritableResource``` that
overrides ```ROOT_URI```, and then create other classes as sub-classes of this:

    require "subjoin"

    module Subjoin
        # Use this class as the parent of further subclasses.
        # They will inherit the ROOT_URI defined here
        class ExampleResource < Subjoin::InheritableResource
            ROOT_URI="http://example.com"
        end

        # Subjoin will make requests to http://example.com/articles
        class Articles < ExampleResource
        end

        # Use TYPE_PATH if you don't want to name the class the same thing as
        # the type
        class ArticleComments < ExampleResource
            TYPE_PATH="comments"
        end
    end

With the classes defined, there are several more options for retrieving data:

    Articles::get                 # http://example.com/articles
    Articles::get("1")            # http://example.com/articles/1
    Document.new("articles")      # http://example.com/articles
	Document.new("articles", "1") # http://example.com/articles/1

Each of these versions returns a ```Document``` and any resources contained in ```data``` will be instantiated as ```Articles``` objects, e.g

    Articles::get.data            # Array of Articles objects
    Articles::get("1").data.first # An Articles object

Furthermore, if there are included resources in the document, they will be
instantiated as whatever matching subclasses of ```InheritableResource``` are
available. If no matching class can be found, they will be instantiated as
```Resource``` objects:

    articles = Articles::get("1")               # Document
    bkshd    = articles.data.first              # an Articles object

    cmnt_id  = bkshd.relationships["comments"]. # first related comment
	             linkages.first                 # resource identifier

    comment  = articles.included[cmnt_id]       # an ArticleComments object
	                                          
    auth_id = bkshd.relationships["author"].    # first related author
                  linkages.first                # resource identifier

    author  = articles.included[auth_id]        # a Resource object, because
                                                # we never defined a custom
	                                            # class for authors resources


## Why is it called "Subjoin"

Nice word. Sounds coder-y. Has most of the letters of "Ruby JSON-API".

## Contributing

1. Fork it ( https://github.com/[my-github-username]/subjoin/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
