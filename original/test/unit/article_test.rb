require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :users
  fixtures :articles

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Article, articles(:first)
  end

  # 正しく保存されるか？
  # 保存後には body が整形されている。
  def test_save
    obj = Article.new
    obj.subject = "題名"
    obj.url = "tp://www.google.co.jp/"
    obj.tag_names = "foo bar"
    obj.body = "  a\nb\nc\n  "
    obj.user_id = 1
    obj.save
    assert_equal(true, obj.save)

    assert_equal("a\nb\nc", obj.body)
  end

  def test_bofere_validation
    assert_equal_before_validation_url("http://", "http://")
    assert_equal_before_validation_url("http://", "ttp://")
    assert_equal_before_validation_url("http://", "tp://")
    assert_equal_before_validation_url("https://", "ttps://")
  end

  def assert_equal_before_validation_url(except, url)
    obj = Article.new
    obj.url = url
    obj.save
    assert_equal(except, obj.url)
  end

  # Emacs用に読み出す
  def test_text_get
    except = <<-EOT
Id: 1
Subject: subject1
Url: http://www.google.co.jp/
From: bob
Tag: 
Created at: 2006/01/01 00:00:00
--text follows this line--
body1
EOT
    assert_equal(except, articles(:first).to_text)
  end

  # Emacsからポストする
  def test_text_post
    post_data = <<-EOT
Id: 
Subject: 題名3
Url: http://www.google.co.jp/
From: bob
Tag: foo bar
--text follows this line--
内容1
内容2
--------------------------------------------------------------------------------
Id: 
Subject: 題名4
Url: http://www.google.co.jp/
From: bob
Tag: foo bar
--text follows this line--
内容1
内容2
EOT
    before_count = Article.count
    result = Article.text_post(post_data)
    assert_match(/個数: 2/, result)
    assert_match(/題名3 create OK/, result)
    assert_match(/題名4 create OK/, result)
    assert_equal(before_count+2, Article.count)
  end
end
