class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def search
    query = params[:filter].to_s.strip
    @users = if query.present?
      User.where("username LIKE ?", "%#{query}%").order(:username).limit(10)
    else
      User.order(:username).limit(10)
    end
    render layout: false
  end
end
