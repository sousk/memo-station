require 'test/unit'

require File.dirname(__FILE__) + '/../lib/mylib.rb'

class MylibTest < Test::Unit::TestCase
  def test_this_plugin
    assert_equal("タイトル", "title".humanize)
    assert_equal("Id", "id".humanize)
    assert_equal("タイトルId", "title_id".humanize)
  end
end
