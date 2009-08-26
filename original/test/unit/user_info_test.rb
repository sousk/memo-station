require File.dirname(__FILE__) + '/../test_helper'

class UserInfoTest < Test::Unit::TestCase
  fixtures :user_infos

  def setup
    @user_info = UserInfo.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of UserInfo,  @user_info
  end
end
