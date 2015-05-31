require "subjoin"

cwd = File.dirname(__FILE__)

ERR404 = IO.read(File.join(cwd, "responses", "404.json"))
ARTICLE = IO.read(File.join(cwd, "responses", "article_example.json"))
COMPOUND = IO.read(File.join(cwd, "responses", "compound_example.json"))
LINKS = IO.read(File.join(cwd, "responses", "links.json"))
META = IO.read(File.join(cwd, "responses", "meta.json"))
