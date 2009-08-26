require File.dirname(__FILE__) + '/../test_helper'
require 'account_controller'

# Set salt to 'change-me' because thats what the fixtures assume.
User.salt = 'change-me'

# Raise errors beyond the default web-based presentation
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase

  fixtures :users

  def setup
    @controller = AccountController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
    @request.host = "localhost"
  end

  def test_auth_bob
    @request.session[:return_to] = "/bogus/location"

    post :login, :loginname => "bob", :password => "test"
    assert_session_has :user

    assert_equal users(:first_user), @response.session[:user]

    assert_redirect_url "http://localhost/bogus/location"
  end

  def test_signup
    @request.session[:return_to] = "/bogus/location"

    post :signup, :user => { :loginname => "newbob", :password => "newpassword", :password_confirmation => "newpassword" }
    assert_session_has :user

    assert_redirect_url "http://localhost/bogus/location"
  end

  def test_bad_signup
    @request.session[:return_to] = "/bogus/location"

    post :signup, :user => { :loginname => "newbob", :password => "newpassword", :password_confirmation => "wrong" }
    assert_invalid_column_on_record "user", :password
    assert_success

    post :signup, :user => { :loginname => "yo", :password => "newpassword", :password_confirmation => "newpassword" }
    assert_invalid_column_on_record "user", :loginname
    assert_success

    post :signup, :user => { :loginname => "yo", :password => "newpassword", :password_confirmation => "wrong" }
    assert_invalid_column_on_record "user", [:loginname, :password]
    assert_success
  end

  def test_invalid_login
    post :login, :loginname => "bob", :password => "not_correct"

    assert_session_has_no :user

    # assert_template_has "login"
  end

  def test_login_logoff

    post :login, :loginname => "bob", :password => "test"
    assert_session_has :user

    get :logout
    assert_session_has_no :user

  end

end
