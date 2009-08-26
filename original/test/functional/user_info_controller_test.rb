require File.dirname(__FILE__) + '/../test_helper'
require 'user_info'

# Re-raise errors caught by the controller.
class UserInfoController; def rescue_action(e) raise e end; end

class UserInfoControllerTest < Test::Unit::TestCase
  def setup
    @controller = UserInfoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
