require File.dirname(__FILE__) + '/../test_helper'
require 'articles_controller'

# Re-raise errors caught by the controller.
class ArticlesController; def rescue_action(e) raise e end; end

class ArticlesControllerTest < Test::Unit::TestCase
  fixtures :users
  fixtures :articles

  def setup
    @controller = ArticlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # セッションなしでアクセスしたときにリダイレクトするか？
  # ログイン後だとリダイレクトしないか？
  def test_new
    get :new
    assert_redirected_to("/login")

#     @request.session[:user] = User.find(:first)
#     get :new
#     assert_success
  end


  def test_text_get
    get :text_get, :query => "a"
    assert_success
  end

end
