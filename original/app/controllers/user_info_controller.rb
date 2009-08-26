class UserInfoController < ApplicationController
  scaffold :user_info
  set_global_navi_category :mypage

  def index
    @user_info = session[:user].user_info
  end

  def profile
    if params[:loginname]
      @user = User.find_by_loginname(params[:loginname])
    elsif params[:id]
      @user = User.find(params[:id])
    end
    raise ArgumentError, "id or loginname required" unless @user
    @articles = @user.articles
  end

  def edit
    @user_info = session[:user].user_info
    if request.post?
      unless @user_info.update_attributes(params[:user_info])
        render :controller => "user_info", :action => 'edit'
        return
      end
      redirect_to :controller => "user_info", :action => "show", :id => session[:user]
    end
  end

end
