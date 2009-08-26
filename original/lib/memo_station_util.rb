# $Id: memo_station_util.rb 600 2006-08-15 22:19:07Z ikeda $

class String
  @@ja_white_space = /[　\s]/
  def ja_strip
    sub(/\A#{@@ja_white_space}*(.*?)#{@@ja_white_space}*\z/, '\1')
  end

  def ja_squeeze_space
    gsub(/#{@@ja_white_space}+/, ' ')
  end

  def ja_clean
    ja_squeeze_space.ja_strip
  end

  def ja_rstrip
    sub(/(.*?)#{@@ja_white_space}*\z/, '\1')
  end
end

# タグが含まれているか調べるとき、あちこちで大小文字の区別をしないよ
# うな処理を書いてしまっていたので専用メソッドを用意した。
class Array
  def tag_include?(tag)
    !!tag_find(tag)
  end

  def tag_find(tag)
    tag = tag.to_s.downcase
    find{|value|value.to_s.downcase == tag}
  end
end

if $0 == __FILE__
  require 'test/unit'

  class TestMemoStationUtil < Test::Unit::TestCase
    def setup
      @string        = "　\n　\t　\n　foo　bar　\n　\t　\n"
      @rstrip_result = "　\n　\t　\n　foo　bar"
    end

    def test_ja_strip
      assert_equal("", "".ja_strip)
      assert_equal("foo　bar", @string.ja_strip)
    end

    def test_ja_squeeze_space
      assert_equal(" foo bar ", @string.ja_squeeze_space)
    end

    def test_ja_clean
      assert_equal("foo bar", @string.ja_clean)
    end

    def test_ja_rstrip
      assert_equal(@rstrip_result, @string.ja_rstrip)
    end

    def test_tag_include?
      assert_equal(true, ["Foo"].tag_include?(:foo))
    end
  end
end
