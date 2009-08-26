#--------------------------------------------------------------------------------
# テスト用の fixture ファイルをDBから動的生成する
# 使い方: ./script/runner "User.to_fixture"
#--------------------------------------------------------------------------------

class ActiveRecord::Base
  def self.to_fixture(limit=nil)
    Pathname("test/fixtures/__#{table_name}.yml").expand_path(RAILS_ROOT).open("w"){|f|
      f.puts self.find(:all, :limit => limit).inject({}){|hash, record|
        hash.merge(record.id => record.attributes)
      }.to_yaml
    }
  end
end
