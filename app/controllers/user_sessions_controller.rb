class UserSessionsController < ApplicationController

  def new
    @user = User.new
  end

  def create
    user = login(params[:email], params[:password])
    if user
      redirect_to root_path
    else
      redirect_to login_path
      flash.alert = 'Неверный пароль или логин'
    end
  end

  def destroy
    logout
    redirect_to root_path
  end
end
