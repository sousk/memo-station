# Mylib

require 'rubygems'
gem 'activerecord'

require File.dirname(__FILE__) + '/english_to_japanese_dictionary.rb'
require File.dirname(__FILE__) + '/palette.rb'
require File.dirname(__FILE__) + '/active_record_fixture.rb'
require File.dirname(__FILE__) + '/date/holiday.rb'


#--------------------------------------------------------------------------------
# フォームのエラーメッセージを日本語化
#--------------------------------------------------------------------------------
# messages = {
#   :inclusion    => "is not included in the list",
#   :exclusion    => "is reserved",
#   :invalid      => "の入力が間違っています。",
#   :confirmation => "の入力内容が一致していません。",
#   :accepted     => "must be accepted",
#   :empty        => "を入力してください。",
#   :blank        => "を入力してください。",
#   :too_long     => "の入力が長すぎます。%d文字以下で入力してください。",
#   :too_short    => "の入力が短かすぎます。%d文字以上入力してください。",
#   :wrong_length => "is the wrong length (should be %d characters)",
#   :taken        => "はすでに登録されています。",
#   :not_a_number => "is not a number",
# }
# ActiveRecord::Errors.default_error_messages.update(messages)


#--------------------------------------------------------------------------------
# 低レベルな英和変換処理
#
# 辞書に title と id だけが登録されているとき次のように変換される。
#
#   "title".humanize    #=> "タイトル"
#   "id".humanize       #=> "番号"
#   "title_id".humanize #=> "タイトル番号"
#   "foo_bar".humanize  #=> "Foo Bar"
#--------------------------------------------------------------------------------
# module Inflector
#   alias_method :humanize_original, :humanize
#   def humanize(lower_case_and_underscored_word)
#     EnglishToJapaneseDictionary[lower_case_and_underscored_word.to_sym] || lower_case_and_underscored_word.to_s.split(/_/).collect{|word|
#       EnglishToJapaneseDictionary[word.to_sym] || humanize_original(word)
#     }.join
#   end
# end


# カレンダー用
# これを入れると休日が反映される。
require "date/holiday"

# カレンダーの曜日を日本語で出すため
class Date
  DAYNAMES_JA = "日月火水木金土".scan(/./)
end

#--------------------------------------------------------------------------------
# 日付フォーマットの定義
# ブログの場合は Time.now.to_s(:bbs) のようにして使う。
# Time.now.to_s は :default の定義が使われる。
#--------------------------------------------------------------------------------
date_formats = {
  :default => "%Y/%m/%d %H:%M:%S",
  :pdf     => "%Y年%m月%d日 %H時%M分",
}
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(date_formats)
