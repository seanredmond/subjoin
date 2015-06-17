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

### Document

Everything starts with a document, specifically a `Subjoin::Document` -- the equivalent of a [JSON-API document](http://jsonapi.org/format/) which you
can create with a URI:

	require "subjoin"
    doc = Subjoin::Document.new(URI("http://example.com/articles"))

(all examples here based on examples in the
[JSON-API documentation](http://jsonapi.org/format/))

Note that you must pass a
[URI object](http://ruby-doc.org/stdlib-2.2.2/libdoc/uri/rdoc/URI.html). A
string would be interpreted as a JSON-API `type`.

A `Subjoin::Document` probably has "primary data" which, if present is an Array
of `Subjoin::Resource` objects:

    doc.has_data?  # true if there is primary data
      => true
    doc.data       # Array of Subjoin::Resource objects
    doc.data.first # One resource

The `data` member of a JSON-API document can be either a single resource object
or an array of resource objects. `Subjoin::Document#data` always returns an
Array. In a document with a single resource object, the Array will have one
element.

You can access all the other members of the [top-level document](http://jsonapi.org/format/#document-top-level) (all the objects returned are covered below):

	doc.links    # Hash of Link objects
	doc.included # Inclusions object
	doc.meta     # Meta object
	doc.jsonapi  # JsonApi object

There are, in addition, methods to test whether any of the above members are
present:

    doc.has_data?
	doc.has_links?
	doc.has_included?
	doc.has_meta?
	doc.has_jsonapi?

### Resources

Every `Subjoin::Resource` has a `type` and `id`. The JSON response:

    {
      "data": {
      "type": "articles",
      "id": "1",
      "attributes": {
        "title": "JSON API paints my bikeshed!"
	  },
	  ...
    }

would correspond to:

    article = doc.data.first
    article.type
	  => "articles"
    article.id
      => "1"

The attributes of a `Subjoin::Resource` object, or any object that
includes `Subjoin::Attributable`, can be accessed like hash on the
object itself:

    article["title"]
      => "JSON API paints my bikeshed!"

You can also get the entire attributes Hash as
`Subjoin::Attributable#attributes`:

    article.attributes # Hash
    article.attributes.keys
      => ["title"]
    article.attributes["title"]
    => "JSON API paints my bikeshed!"

The other expected members of a
[resource object](http://jsonapi.org/format/#document-resource-objects) are
available. The objects returned by these methods are all explained below:

    article.links         # Hash of Link objects
    article.relationships # Array of Relationship objects
    article.meta          # Meta object

As with `Subjoin::Document`, there are methods to see if any of the above are available

    article.has_links?
	article.has_meta?

### Links

`Subjoin::Document`, `Subjoin::Resource`, and `Subjoin::Relationship` can all
have [links](http://jsonapi.org/format/#document-links). They all have
the `Subjoin::Linkable#links` method which returns a Hash of `Subjoin::Link`
objects:

	article.links.keys
	  => ["self"]
    article.links["self"].href.to_s
      => "http://example.com/articles/1"

JSON-API allows for two link object formats. One simply has a link

    "links": {
      "self": "http://example.com/articles/1"
    }

and one has an `href` attribute and `meta` object:

    "links": {
      "related": {
        "href": "http://example.com/articles/1/comments",
        "meta": {
          "count": 10
        }
      }
    }

Subjoin treats either variation like the latter:

    article.links["self"].href.to_s
      => "http://example.com/articles/1"
    article.links["self"].has_meta?
      => false
    article.links["self"].meta?
      => nil

    article.links["related"].href.to_s
      => "http://example.com/articles/1/comments"
    article.links["related"].has_meta?
      => true
    article.links["related"].meta["count"]
      => 10

Note that the `href` is always returned as a `URI` object. If you have a `Subjoin::Link` you can get the corresponding `Subjoin::Document`:

    article.links["related"].get # Same thing as Subjoin::Document.new
                                 # with the URL

### Resource Identifiers

Before getting to relationships, we should take a minute to look at
[resource identifiers](http://jsonapi.org/format/#document-resource-identifier-objects). Above,
we saw that every `Subjoin::Resource` has a `type` and `id`.

    article.type # "articles"
	article.id   # "1"

Though the above attributes exist individually, these two attributes
work together as a compound key and are, in fact put together in
Subjoin as a `Subjoin::Identifier` object:

    article.identifier      # Identifier object
    article.identifier.type # "articles"
	article.identifier.id   # "1"

`Subjoin::Identifier` objects are used for equality: two
`Subjoin::Resource` objects are considered equal if they have equal
`Identifer`s:

    article1 == article2                                    # Really tests...
    article1.identifier == article2.identifier              # Really tests...
	article1.identifier.type == article2.identifier.type &&
	    article1.identifer.id == article2.identifier.id

More importantly, identifiers occur in Relationship objects as
pointers to other resources. These pointers are called
[linkages](http://jsonapi.org/format/#document-resource-object-linkage):

    article.relationships.author.linkages # Array of Identifier objects

They may have, optionally, a `meta` attribute as well, and `meta`
attributes are ignored in tests for equality.

### Relationships, Linkages, Included Resources

Okay, now we can get to how you'll really use JSON-API resources and why you would JSON-API over other options: resource linking and included resources.

In many RESTful APIs, resources have embedded child resources which
is, in my experience, a principle source of the bikeshedding arguments
that JSON-API tries to avoid ("should X be a child of Y, or Y a child
of X?" "How should the X response be different when it is achild of
another resource?"). Instead of nesting and embedding, in JSON-API
resources may have
[relationships](http://jsonapi.org/format/#document-resource-object-relationships)
to other resources.

    article.relationships        # A Hash of Subjoin::Relationship objects
    article.relationships.keys
      => ["author", "comments"]

This much tells you that an "article" can have an "author" and
"comments". In Subjoin, relationships are instantiated as
`Subjoin::Relationship` objects whose two important properties are
`links` and `linkages`. `Subjoin::Relationship` are
`Subjoin::Linkable` so `links` works as it does in other objects.

    author = article.relationships["author"]    # Relationship object
	author.links.keys
      => ["self", "related"]
    author.links["related"].to_s
      => "http://example.com/articles/1/author"
    author.links["related"].get                 # Get a new Document

Alongside `links`, `linkages` give you resource identifiers for the
related resources. while the "comments" `link` tells us how to get a
document with all the related comments:

    comments.links["self"].to_s
      => "http://example.com/articles/1/relationships/comments"

The corresponding `linkages` returns an Array of
`Subjoin::Identifier` that are pointers to specific resources:

    comments = article.relationships["comments"]
    comments.linkages.count
      => 2

This tells us that there are two related comments. If we look at one,
we can get the type and id:

    comments.linkages[0].type
      => "comments"
    comments.linkages[0].id
      => "5"

So far so good, but now what? [Inclusion](http://jsonapi.org/format/#fetching-includes)

With JSON-API, you can request that these related resources be included in the document, one of three ways:

    # URI parameters
    doc = Subjoin::Document.new(URI("http://example.com/articles/1?include=author,comments"))

    # Parameters Hash with a string
    doc = Subjoin::Document.new(URI("http://example.com/article/1s", {"include" => "author,comments"}))

    # Parameters Hash with an array of strings
    doc = Subjoin::Document.new(URI("http://example.com/articles/1", {"include" => ["author" ,"comments"]}))

All three are equivalent. The array of strings version works especially well with relationship keys

    doc2 = Subjoin::Document.new(URI("http://example.com/articles/1", {"include" => articles.relationships.keys}))

When a document is requested with included resources, they can be accessed via `included`

    # Get the document
    doc = Subjoin::Document.new(URI("http://example.com/articles/1", {"include" => ["author" ,"comments"]}))

	# Get the article
    article = doc.data.first

	# Get the realted author identifier
    auth_identifier = article.related["author"].linkages.first
    auth_identifier.type
      => "people"
    auth_identifier.id
      => "9"

    # Get the embedded resource
    doc.has_included?
      => true

    # Look up included resource by identifier
    author = doc.included[auth_identifier]

    # Now we have access to the whole author resource
	author.type
      => "people"
    author.id
      => "9"
    author["twitter"]
      => "dgeb"

If that sounds kind of complicated, it is. But you can...

### Let Subjoin resolve the linkages for you

To make all this easier, `Subjoin::Resource` provides a `rels` method that does all this under the hood:

    article.rels.keys
      => ["author", "comments"]
    author = article.rels["author"] # Returns the author Resource
    author["twitter"]
      => "dgeb"

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

Another way to use Subjoin is via inheritance. Using this approach you
create your own classes to represent JSON-API resource types of a
specific JSON-API server implementation. These classes must be
sub-classes of `Subjoin::Resource` and must include
`Subjoin::Inheritable`, which adds some constants and methods that
`Subjoin::Document` will use to instantiate objects correctly. Next
you must override a class variable, `ROOT_URI`, which should be the
root of all URIs of the API. For instance, in the examples above,
"http://example.com" would be the value of `ROOT_URI`. By default,
Subjoin will use the lower-cased name of the class as the type in
URIs. If the class name does not match the type, you can further
override `TYPE_PATH` to indicate the name (or longer URI fragment)
that should be used in URIs to request the resource type.

Your custom classes must also be part of the ```Subjoin``` module. You
should probably create one sub-class of `Subjoin::Resource` that
overrides `ROOT_URI`, and then create other classes as sub-classes of
this:

    require "subjoin"

    module Subjoin
      # Use this class as the parent of further subclasses.
      # They will inherit the ROOT_URI defined here
      class ExampleResource < Subjoin::Resource
        include Inheritable
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

Now, when you get a document, the resources in it will be mapped to an available type:

    doc = Subjoin::Document.new(URI("http://example.com/articles/1", {"include" => ["author" ,"comments"]}))

	# We mapped the article type to the Article class
    article = doc.data.first
    article.class
      => Subjoin::Article

    # We mapped the comment type to the ArticleComment class
    comment = article.rels["comments"].first
    comment.class
      => Subjoin::ArticleComment

	# We didn't map the person type to anything, so we get a Resource
	author = article.rels["author"].first
    author.class
      => Subjoin::Resource


## Why is it called "Subjoin"

Nice word. Sounds coder-y. Has most of the letters of "Ruby JSON-API".

## Contributing

1. Fork it ( https://github.com/seanredmond/subjoin/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
