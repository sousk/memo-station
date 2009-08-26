#!/usr/local/bin/ruby -Ku

require File.dirname(__FILE__) + "/../config/environment"

db_query('select * from user_infos\G')
db_query('select * from users')
db_query('select * from articles')
