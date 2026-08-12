class PagesController < ApplicationController
  def home
    @app_name = "QuestLog"
    @today = Date.today
    @current_time = Time.current.strftime("%H:%M:%S")

    @current_quests = Quest.visible_to(current_user).where(completed: false)
    @completed_quests = Quest.visible_to(current_user).where(completed: true)

    @low_difficulty = @completed_quests.where("xp_reward < ?", 30).count
    @medium_difficulty = @completed_quests.where("xp_reward >= ? AND xp_reward < ?", 30, 70).count
    @high_difficulty = @completed_quests.where("xp_reward >= ?", 70).count
  end

  def switch_user
    session[:user_id] = params[:user_id]
    redirect_to request.referer || root_path
  end

  def quest
  end
end
