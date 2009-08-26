#!/usr/local/bin/ruby -Ku

require File.dirname(__FILE__) + "/../config/environment"

User.delete_all
UserInfo.delete_all

%w(admin ikeda).each{|loginname|
  User.new(:loginname => loginname, :password => loginname, :password_confirmation => loginname).save!
}

user_info = User.find_by_loginname("ikeda").user_info
user_info.name_kanji1 = "池田"
user_info.name_kanji2 = "晃"
user_info.pc_email = "ikeda@dream.big.or.jp"
user_info.mobile_email = "sancha-akira@docomo.ne.jp"
user_info.save!

db_query('select * from users')
db_query('select * from user_infos\G')
