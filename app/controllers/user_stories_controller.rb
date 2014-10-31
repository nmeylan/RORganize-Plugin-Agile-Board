class UserStoriesController < ApplicationController
  before_action :set_user_story, only: [:show, :edit, :update, :destroy]

  # GET /user_stories
  def index
    @user_stories = UserStory.all
  end

  # GET /user_stories/1
  def show
  end

  # GET /user_stories/new
  def new
    @user_story = UserStory.new
  end

  # GET /user_stories/1/edit
  def edit
  end

  # POST /user_stories
  def create
    @user_story = UserStory.new(user_story_params)

    if @user_story.save
      redirect_to @user_story, notice: 'User story was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /user_stories/1
  def update
    if @user_story.update(user_story_params)
      redirect_to @user_story, notice: 'User story was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /user_stories/1
  def destroy
    @user_story.destroy
    redirect_to user_stories_url, notice: 'User story was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_story
      @user_story = UserStory.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_story_params
      params.require(:user_story).permit(:title, :description, :status_id, :points, :position, :author_id, :epic_id, :tracker_id, :sprint_id, :project_id, :category_id)
    end
end
