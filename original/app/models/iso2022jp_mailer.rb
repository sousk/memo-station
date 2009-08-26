# http://wota.jp/ac/?date=20050731#p01

# app/model/iso2022jp_mailer.rb

class Iso2022jpMailer < ActionMailer::Base
  @@default_charset = 'iso-2022-jp'  # これがないと "Content-Type: charset=utf-8" になる
  @@encode_subject  = false          # デフォルトのエンコード処理は行わない(自分でやる)

  # 1) base64 の符号化 (http://wiki.fdiary.net/rails/?ActionMailer より)
  def self.base64(text, charset="iso-2022-jp", convert=true)
    if convert
      if charset == "iso-2022-jp"
        text = NKF.nkf('-j -m0', text)
      end
    end
    "=?#{charset}?B?#{TMail::Base64.rb_encode(text)}?="
  end

  # 2) 本文を iso-2022-jp へ変換
  # どこでやればいいのか迷ったので、とりあえず create! に被せています
  def create! (*)
    super
    @mail.body = @mail.body.tojis
    @mail # メソッドチェインを期待した変更があったら怖いので
  end
end
