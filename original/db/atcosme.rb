#!/usr/local/bin/ruby -Ku
# Time-stamp: <2006-03-03 19:21:50 ikeda>

require File.dirname(__FILE__) + "/../config/environment"

Article.delete_all
Tag.delete_all

[
  "/home/ikeda/src/x/runchar.rb",
  "/home/ikeda/src/x/command_cosme.rb",
].each{|fname|
  # load fname
  eval Pathname(fname).expand_path.read.toutf8
}

class Cosmestable13Command

  def memo_station_import
    memo_station_import_view
  end

  def memo_station_import_view
    files = []
    # files << Pathname("/home/ikeda/src/stable_ver1.3/webapp/modules/add/views/add_askSuccessView.class.php")
    files += target_success_views
    files.each{|fname|
      puts "read: #{fname}"
      view_file_info = view_file_info(fname)
      # p view_file_info

      controller = "#{fname.dirname.dirname.basename}"
      subdir = fname.dirname.dirname.dirname.basename.to_s.match(/backend/) ? "merge-user" : "merge-back"
      action = fname.to_s.match(/([a-z]\w+)SuccessView/).captures.first
      rnew_url = "http://rnew.cosme.net/#{subdir}/#{controller}/#{action}"

      # 【アクション一覧】
      # ME03_main1
#       action_names = []
#       view_file_info[:yaml_file_infos].each{|hash|
#         if hash[:module_name] == controller
#           action_names << hash[:op_num]
#         end
#       }

      base_tags = []
      base_tags << controller
      base_tags << action
      base_tags << "cosme"
      base_tags << action.split(/_/)

      # そのまま飛べるURL
      article = Article.new
      article.title = "#{action} of #{controller} (#{subdir})"
      article.body = ""
      article.url = rnew_url
      article.tag base_tags
      article.tag "url"
      article.save!

      # 関連パーツ
      view_file_info[:yaml_file_infos].each{|hash|
        # 【アクション一覧】
        article = Article.new
        article.title = "#{hash[:action_file]}"
        article.body = hash[:action_file].read
        article.url = nil
        article.tag base_tags
        article.tag "action"
        article.tag hash[:op_num].downcase
        article.tag hash[:op_num].downcase.split(/_/)
        article.tag relative_tables(hash[:action_file])
        article.save!

        # 【テンプレート】
        article = Article.new
        article.title = "#{hash[:template]}"
        article.body = hash[:template].read
        article.url = nil
        article.tag base_tags
        article.tag "template"
        article.tag hash[:op_num].downcase
        article.tag hash[:op_num].downcase.split(/_/)
        article.tag relative_tables(hash[:action_file])
        article.save!
      }
    }
  end

end

Cosmestable13Command.new.memo_station_import
p Article.count

# REM: ----------------------------------------
# REM: ファイル名: /home/ikeda/src/stable_ver1.3/webapp/modules/monitor/views/detailSuccessView.class.php
# REM: YAML名: /home/ikeda/src/stable_ver1.3/webapp/modules/monitor/config/layout/ME03.yaml
# REM: テンプレート名: /home/ikeda/src/stable_ver1.3/webapp/modules/monitor/templates/dummy.html
# [monitor/detail]
# 【ページ概要】
# 応募ポップアップを表示する。
# REM: /home/ikeda/src/svn/trunk/document/documents/PS/detail_design/webapp/modules/monitor/actions/ME03_main1Action.class.php
# REM: /home/ikeda/src/svn/trunk/document/documents/PS/detail_design/webapp/modules/common/actions/headerAction.class.php
# 【関連テンプレート】
# REM: /home/ikeda/src/stable_ver1.3/webapp/modules/monitor/templates/ME03_main1.html
# REM: /home/ikeda/src/stable_ver1.3/webapp/modules/common/templates/header.html
# 【URL】
# http://www.cosme.net/monitor/detail
# http://rnew.cosme.net/merge-user/monitor/detail
# 【アクション一覧】
# ME03_main1
# header[common]
# 【関連テーブル】
# member_address
# monitor


# {:template=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/add/templates/dummy.html>, :layout_module=>"add", :yaml_file=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/add/config/layout/RK23.yaml>, :yaml_file_infos=>[{:template=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/add/templates/RK17_main1.html>, :op_num=>"RK17_main1", :action_file=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/add/actions/RK17_main1Action.class.php>, :module_name=>"add"}, {:template=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/add/templates/RK23_main2.html>, :op_num=>"RK23_main2", :action_file=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/add/actions/RK23_main2Action.class.php>, :module_name=>"add"}, {:template=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/common/templates/rightside1.html>, :op_num=>"rightside1", :action_file=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/common/actions/rightside1Action.class.php>, :module_name=>"common"}, {:template=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/common/templates/header.html>, :op_num=>"header", :action_file=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/common/actions/headerAction.class.php>, :module_name=>"common"}, {:template=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/common/templates/footer.html>, :op_num=>"footer", :action_file=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/common/actions/footerAction.class.php>, :module_name=>"common"}], :basedir=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/add>, :view_file=>#<Pathname:/home/ikeda/src/stable_ver1.3/webapp/modules/add/views/add_askSuccessView.class.php>}


  # add_relative_tables(view_file_info)

#   p view_file_info


#       @appdoc_log = ""
#     @appdoc_txt = @appdoc_dir + "appdoc.views.txt"
#     target_success_views.each{|fname|
#       puts "read: #{fname}"
#       controller = "#{fname.dirname.dirname.basename}"
#       controller_action = "#{controller}/#{md.captures.first}"
#       url = "http://www.cosme.net/#{controller_action}"
#       url2 = "http://rnew.cosme.net/merge-user/#{controller_action}"
#       view_file_info = view_file_info(fname)
#       add_relative_tables(view_file_info)

#       @appdoc_log << "REM: " + "-" * 40 + "\n"
#       @appdoc_log << "REM: ファイル名: #{fname}\n"
#       @appdoc_log << "REM: YAML名: #{view_file_info[:yaml_file]}\n"
#       @appdoc_log << "REM: テンプレート名: #{view_file_info[:template]}\n"
#       @appdoc_log << "\f[#{controller_action}]\n"

#       @appdoc_log << "【ページ概要】\n"
#       body = []
#       if view_file_info[:yaml_file_infos].empty?
#       else
#         view_file_info[:yaml_file_infos].map{|hash|
#           file_body = file_body(hash[:action_file])
#           unless file_body.empty?
#             @appdoc_log << "#{file_body}\n"
#           end
#         }
#       end

#       if view_file_info[:yaml_file_infos].empty?
#         @appdoc_log << "REM: (layoutは見ない)\n"
#       else
#         view_file_info[:yaml_file_infos].each_with_index{|hash, index|
#           @appdoc_log << "REM: #{@appdoc_dir + hash[:action_file].relative_path_from(@devel_root)}\n"
#         }
#       end
#       @appdoc_log << "【関連テンプレート】\n"
#       unless view_file_info[:yaml_file_infos].empty?
#         view_file_info[:yaml_file_infos].each{|hash|
#           @appdoc_log << "REM: #{hash[:template]}\n"
#         }
#       end


#       @appdoc_log << "【URL】\n"
#       @appdoc_log << "#{url}\n"
#       @appdoc_log << "#{url2}\n"

#       @appdoc_log << "【アクション一覧】\n"
#       view_file_info[:yaml_file_infos].each{|hash|
#         common_comment = nil
#         if hash[:module_name] != controller
#           common_comment = "[#{hash[:module_name]}]"
#         end
#         @appdoc_log << "#{hash[:op_num]}#{common_comment}\n"
#       }

#       @appdoc_log << "【関連テーブル】\n"
#       view_file_info[:relative_tables].each{|table|
#         @appdoc_log << "#{table}\n"
#       }
#       @appdoc_log << "\n"
#     }
#     @appdoc_txt.open("w"){|f|f << @appdoc_log.to_shift_jis_dos}
#     puts "write: #{@appdoc_txt}"


