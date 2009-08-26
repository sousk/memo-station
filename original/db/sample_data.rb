#!/usr/local/bin/ruby

require File.dirname(__FILE__) + "/../config/environment"

Article.delete_all
Article.create(:title => "(title)", :body => "(body)")
Article.create(:title => "(title)", :body => "(body)")
Article.create(:title => "(title)", :body => "(body)")
p Article.find_all
