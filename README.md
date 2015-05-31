# Subjoin

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'subjoin'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install subjoin

## Usage

The simplest starting point is to pass a URL (as a string or URI object) to ```Subjoin::resources``` which will return a ```Subjoin::Resource```, a ```Subjoin::CompoundDocument``` or raise an error based on the response received.

Get a compound document:

    @doc = Subjoin::resource(URI("http://example.com/articles"))
    @doc.resources.first.type  # "articles"
    @doc.resources.first.id    # "1"
    @doc.resources.first.title # "JSON API paints my bikeshed!"

Get a single resource:

    @doc = Subjoin::resource(URI("http://example.com/articles/1"))
    @doc.type  # "articles"
    @doc.id    # "1"
    @doc.title # "JSON API paints my bikeshed!"

### Resources

Given this JSON:

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

    article = Subjoin::resource(URI("http://example.com/articles/1"))
    article.type                         # "articles"
    article.id                           # "1"
	article.links                        # A Subjoin::Links object
	article.links["self"].href           # "http://example.com/articles/1"
    article.relationships                # A Hash of Subjoin::Relationship objects
    article.relationships.keys           # ["author", "comments"]
	article.relationships["author"].type # "people"

Attributes are accessible directly through the object or through the
```attributes Hash

    article.title               # Both return 
    article.attributes["title"] # "JSON API paints my bikeshed!"

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

	


	

## Contributing

1. Fork it ( https://github.com/[my-github-username]/subjoin/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
