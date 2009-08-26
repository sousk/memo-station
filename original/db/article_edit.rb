#!/usr/local/bin/ruby

require File.dirname(__FILE__) + "/../config/environment"

class Foo
  def initialize
    Article.text_post(ARGF.read)
  end
end

if $0 == __FILE__
  Foo.new
end
