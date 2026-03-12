class PagesController < ApplicationController
  def home
    @app_name = "QuestLog"
    @today = Date.today
    @current_time = Time.current.strftime("%H:%M:%S")
  end

  def quest
    
  end
end