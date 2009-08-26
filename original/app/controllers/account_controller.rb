class AccountController < ApplicationController
  def signup
    @user = User.new(params[:user])
    if request.post?
      if @user.save
        session[:user] = User.authenticate(@user.loginname, params[:user][:password])
        flash[:notice]  = "登録が完了しました。"
        redirect_to_top
        return
      end
    end
  end

  def loginname_input_remote
    render(:update){|page|
      page.replace_html :loginname_warn, User.find_by_loginname(params[:loginname].strip) ? "(すでに使われています)" : ""
    }
  end

  def login
    if session[:user]
      flash[:notice]  = "すでにログイン済みです。"
      redirect_to_top
      return
    end

    if request.post?
      if session[:user] = User.authenticate(params[:loginname], params[:password])
        flash[:notice]  = "ログインしました。"
        redirect_to_top
        return
      else
        flash[:notice] = render_to_string :partial => "login_failure"
      end
    end
  end

  def logout
    session[:user] = nil
    flash[:notice]  = "ログアウトしました。"
    redirect_to :controller => "articles"
  end

  private
  def redirect_to_top
    redirect_back_or_default :controller => "articles"
  end

end
