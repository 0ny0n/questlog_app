class QuestsController < ApplicationController
  def index
    @quests = Quest.where(completed: false)
  end

  def new
    @quest = Quest.new
  end

  def create
    @quest = current_user.quests.new(quest_params) # (params.require(:quest).permit(:title, :description, :xp_reward))
    if @quest.save
      redirect_to quests_path, flash: { success: "Quest create successfully!" }
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @quest = Quest.find(params[:id])
  end

  def update
    @quest = Quest.find(params[:id])

    if @quest.update(quest_params)
      redirect_to quests_path, flash: { success: "Quest updated!" }
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quest = Quest.find(params[:id]) # Cari dulu id Quest yg mau didelete
    @quest.destroy

    redirect_to quests_path, flash: { warning: "Quest deleted!" }
  end

  def archive
    @quests = Quest.where(completed: true)
  end

  def complete
    @quest = Quest.find(params[:id])
    @quest.update(completed: true)

    current_user.gain_xp(@quest.xp_reward)

    redirect_to quests_path
  end

  private
  def quest_params
    params.require(:quest).permit(:title, :description, :xp_reward)
  end
end

# Display All Quests -> Quest.all
# Create New Quests -> Quest.new
# Update Quests -> Quest.find(id)
# Delete Quests -> Quest.destroy
