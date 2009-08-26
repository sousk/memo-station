require File.dirname(__FILE__) + '/../test_helper'
require 'mailman'

class MailmanTest < Test::Unit::TestCase
  fixtures :users
  fixtures :articles

  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  CHARSET = "iso-2022-jp"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :smtp
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @controller = ArticlesController.new
    @request, @response = ActionController::TestRequest.new, ActionController::TestResponse.new
  end

  # テンプレート: ~/src/memo_station/app/views/mailman/article_update.rhtml
  def test_article_update
    article = articles(:first)
    args = [@controller, Time.now, {:article => {:before => article, :after => article}}]
    mail = Mailman.create_article_update(*args)
    assert(mail.subject.include?(article.subject))

    # 実際に送信
    mail_text = Mailman.deliver_article_update(*args).to_s
    # puts mail_text
  end

  # テンプレート: ~/src/memo_station/app/views/mailman/exception_notification.rhtml
  def test_exception_notification
    exception = ArgumentError.new
    args = [@controller, @request, exception, Time.now]

    mail = Mailman.create_exception_notification(*args)

    # 実際に送信
    mail_text = Mailman.deliver_exception_notification(*args).to_s
    # puts mail_text
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/mailman/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end
