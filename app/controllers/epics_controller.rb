class EpicsController < AgileBoardController
  before_action :set_epic, only: [:show, :edit, :update, :destroy]

  # GET /epics
  def index
    @epics = Epic.all
  end

  # GET /epics/1
  def show
  end

  # GET /epics/new
  def new
    @epic = Epic.new
  end

  # GET /epics/1/edit
  def edit
  end

  # POST /epics
  def create
    @epic = Epic.new(epic_params)

    if @epic.save
      redirect_to @epic, notice: 'Epic was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /epics/1
  def update
    if @epic.update(epic_params)
      redirect_to @epic, notice: 'Epic was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /epics/1
  def destroy
    @epic.destroy
    redirect_to epics_url, notice: 'Epic was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_epic
      @epic = Epic.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def epic_params
      params.require(:epic).permit(:name, :description)
    end
end
