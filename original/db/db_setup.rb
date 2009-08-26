#!/usr/local/bin/ruby -Ku
# Rubyツールテンプレート
# Time-stamp: <2006-07-06 16:30:07 ikeda>
# $Id: db_setup.rb 419 2006-07-06 08:47:06Z ikeda $

print `mysql -u root -e 'drop database if exists memo_station_development'`
print `mysql -u root -e 'drop database if exists memo_station_production'`
print `mysql -u root -e 'drop database if exists memo_station_test'`

print `mysql -u root -e 'create database memo_station_development DEFAULT CHARACTER SET utf8'`
print `mysql -u root -e 'create database memo_station_production  DEFAULT CHARACTER SET utf8'`
print `mysql -u root -e 'create database memo_station_test        DEFAULT CHARACTER SET utf8'`

print `rake RAILS_ENV=development  db:schema:load`
print `rake RAILS_ENV=production   db:schema:load`

print `rake RAILS_ENV=development  db:schema:dump`
print `rake db:test:clone_structure`

# require File.dirname(__FILE__) + "/../config/environment"


# puts `cd ..; rake migrate`
# puts `cd ..; rake create_sessions_table`
# puts `cd ..; rake clone_structure_to_test`

load "./user.rb"
load "./article.rb"
load "./check.rb"
