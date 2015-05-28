require "subjoin"

cwd = File.dirname(__FILE__)

ERR404 = IO.read(File.join(cwd, "responses", "404.json"))
COMPOUND = IO.read(File.join(cwd, "responses", "compound_example.json"))
