class UsersController < ApplicationController
  before_action :require_login

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(user_params)
      flash[:notice] = "Profile updated successfully"
      redirect_to edit_user_path
    else
      flash[:alert] = "Failed to update profile"
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :bio)
  end
end
