class Mailman < Iso2022jpMailer
  # メモの新規か更新の際に管理者にメールする
  # @recipients は宛先のこと
  # @body に渡した assigns の中のキーがテンプレート内で @key のように参照できる
  # Articleのモデルの中組み込むか、コントローラーの中に入れるか悩みどころ。
  def article_update(controller, sent_on = Time.now, assigns = {})
    if assigns[:article][:before].new_record?
      info = "新規"
    else
      info = "更新"
    end
    @subject    = Iso2022jpMailer.base64("[#{APPLICATION_TITLE}:メモ#{info}:#{ENV["RAILS_ENV"]}:#{assigns[:article][:after].id}] #{assigns[:article][:after].subject}")
    @body       = {:controller => controller}.merge(assigns)
    @from       = "#{Iso2022jpMailer.base64(AdminName)} <#{AdminMail}>"
    @recipients = "#{Iso2022jpMailer.base64(AdminName)} <#{AdminMail}>"
    @sent_on    = sent_on
    @headers    = {}
  end

  # エラーが起きたときに管理者にメールする
  def exception_notification(controller, request, exception, sent_on = Time.now)
    @subject    = Iso2022jpMailer.base64("[ERROR] #{controller.controller_name}\##{controller.action_name} (#{exception.class}) #{exception.message.inspect}")
    @body = {
      "controller" => controller,
      "request"    => request,
      "exception"  => exception,
      "backtrace"  => sanitize_backtrace(exception.backtrace),
      "host"       => request.env["HTTP_HOST"],
      "rails_root" => rails_root,
    }
    @sent_on    = sent_on
    @from       = "#{Iso2022jpMailer.base64(AdminName)} <#{AdminMail}>"
    @recipients = "#{Iso2022jpMailer.base64(AdminName)} <#{AdminMail}>"
    @headers    = {}
  end

  private
  def sanitize_backtrace(trace)
    return [] unless trace
    re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
    trace.map{|line|
      Pathname(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s
    }
  end

  def rails_root
    @rails_root ||= Pathname(RAILS_ROOT).expand_path.to_s
  end
end
