#!/usr/local/bin/ruby -Ku
# Time-stamp: <2006-07-11 13:52:36 ikeda>

require File.dirname(__FILE__) + "/../config/environment"

Article.delete_all
Tag.delete_all

obj = Article.new
obj.subject = "題名1"
obj.body = "内容"
obj.user = User.find_by_loginname("ikeda")
obj.tag_names = ["foo", "bar"]
obj.save!

db_query("select * from articles\\G")

