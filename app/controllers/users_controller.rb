class UsersController < ApplicationController
  before_action :auth_user, only: %i[show destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      auto_login(@user)
      redirect_to root_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :middle_name, :last_name, :region, :email, :password, :password_confirmation)
  end

  def auth_user
    redirect_to root_path unless params[:id].to_s == current_user.id.to_s
  end
end
