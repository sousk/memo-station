require File.dirname(__FILE__) + '/../test_helper'
require 'stylesheet_controller'

class StylesheetController; def rescue_action(e) raise e end; end

class StylesheetControllerTest < Test::Unit::TestCase
  def setup
    @controller = StylesheetController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_main
    get :style
    assert_success

    get :base
    assert_success
  end
end
