require File.dirname(__FILE__) + '/../test_helper'

# Set salt to 'change-me' because thats what the fixtures assume.
User.salt = 'change-me'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def test_auth
    assert_equal(users(:first_user), User.authenticate("bob", "test"))
    assert_nil(User.authenticate("nonbob", "test"))
  end

  def test_disallowed_passwords
    user = User.new
    user.loginname = "nonbob"

    if false
      user.password = user.password_confirmation = "a" * 3
      assert !user.save
      assert user.errors.invalid?('password')
    end

    user.password = user.password_confirmation = "a" * 21
    assert !user.save
    assert user.errors.invalid?('password')

    user.password = user.password_confirmation = ""
    assert !user.save
    assert user.errors.invalid?('password')

    user.password = user.password_confirmation = "bobs_secure_password"
    assert user.save
    assert user.errors.empty?
  end

  def test_bad_logins

    user = User.new
    user.password = user.password_confirmation = "bobs_secure_password"

    user.loginname = "x"
    assert !user.save
    assert user.errors.invalid?('loginname')

    user.loginname = "a" * 41
    assert !user.save
    assert user.errors.invalid?('loginname')

    user.loginname = ""
    assert !user.save
    assert user.errors.invalid?('loginname')

    user.loginname = "okbob"
    assert user.save
    assert user.errors.empty?
  end

  def test_collision
    user = User.new
    user.loginname = "bob"
    user.password = user.password_confirmation = "bobs_secure_password"
    assert_equal(false, user.save)
  end

  def test_create
    user = User.new
    user.loginname = "nonexistingbob"
    user.password = user.password_confirmation = "bobs_secure_password"
    assert_equal(true, user.save)
  end

  def test_sha1
    user = User.new
    user.loginname = "nonexistingbob"
    user.password = user.password_confirmation = "bobs_secure_password"
    assert_equal(true, user.save)

    assert_equal '98740ff87bade6d895010bceebbd9f718e7856bb', user.password
  end
end
