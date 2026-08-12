class QuestsController < ApplicationController
  before_action :set_quest, only: [ :show, :edit, :update, :destroy, :complete ]
  before_action :authorize_creator!, only: [ :edit, :update, :destroy ]

  def index
    base_query = Quest.visible_to(current_user).where(completed: false)
    @quests = apply_tab_filter(base_query)
  end

  def show
    unless @quest.user_id == current_user.id || @quest.collaborators.include?(current_user)
      redirect_to quests_path, flash: { danger: "You are not authorized to view this quest." }
    end
  end

  def new
    @quest = Quest.new
  end

  def create
    @quest = current_user.quests.new(quest_params)
    if @quest.save
      redirect_to quests_path, flash: { success: "Quest created successfully!" }
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @quest.update(quest_params)
      redirect_to @quest, flash: { success: "Quest updated!" }
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @quest.destroy
    redirect_to quests_path, flash: { warning: "Quest deleted!" }
  end

  def archive
    base_query = Quest.visible_to(current_user).where(completed: true)
    @quests = apply_tab_filter(base_query)
  end

  def complete
    @quest.mark_participant_complete!(current_user)

    if @quest.completed?
      flash[:success] = "All adventurers completed the quest! Quest archived."
    else
      flash[:success] = "You completed your part! (+#{@quest.xp_reward} XP earned)"
    end

    redirect_to request.referer || quests_path
  end

  private

  def set_quest
    @quest = Quest.find(params[:id])
  end

  def authorize_creator!
    unless @quest.user_id == current_user.id
      redirect_to quests_path, flash: { danger: "Only the creator can perform this action." }
    end
  end

  def apply_tab_filter(query)
    case params[:filter]
    when "my_quests"
      query.created_by(current_user)
    when "shared"
      query.collaborative
    else # "all"
      query
    end
  end

  def quest_params
    params.require(:quest).permit(:title, :description, :xp_reward)
  end
end

# Display All Quests -> Quest.all
# Create New Quests -> Quest.new
# Update Quests -> Quest.find(id)
# Delete Quests -> Quest.destroy
