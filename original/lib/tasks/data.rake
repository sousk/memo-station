# $Id$

# インストール関連

require "rake/contrib/sys"

namespace "data" do
#  desc "DBに仮データを作成する"
#   task :sample => [:environment] do
#     5.times{|i|
#       loginname = "ikeda#{i}"
#       user = User.create(:loginname => loginname, :password => loginname, :password_confirmation => loginname)
#     }

  desc "DBに入っているデータを確認する"
  task :check => :environment do
    db_query "select * from users"
    db_query "select * from user_infos"
    db_query "select * from articles"
    db_query "select * from article_view_logs"
  end
end
