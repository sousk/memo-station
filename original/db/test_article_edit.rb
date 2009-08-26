#!/usr/local/bin/ruby -Ke
# Time-stamp: <2006-06-29 05:10:24 ikeda>
# $Id: test_article_edit.rb 614 2006-08-27 18:53:21Z ikeda $

require 'test/unit'
require 'pathname'

class TestMain < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  def test_main
    Pathname("__tmpfile").open("w"){|f|
      f.print(<<EOT)
Subject: (title)
From: Akira Ikeda <ikeda@dream.big.or.jp>
Tag: foo bar
--text follows this line--
a
b
EOT
    }
    assert_match(/\d+/, `cat __tmpfile | ./article_edit.rb`)
  end
end
