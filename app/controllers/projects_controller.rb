class ProjectsController < ApiController
  skip_before_action :authenticate_user!, only: [:index]
  before_action :set_project, only: [:show, :update, :destroy]

  # GET /projects
  # GET /projects.json
  def index
    @projects = Project.all

    render json: @projects
  end

  def trello_boards
    render json: current_user.trello_open_boards
  end

  def trello_lists
    board = current_user.trello_open_boards.find {|b| b.id == params[:board_id] }
    if board
      render json: current_user.trello_open_lists(board.id)
    else
      render json: []
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    render json: @project
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = TrelloProject.new(project_params)
    @project.user = current_user
    # @project = Project.new(project_params) # não serao permitidos outros tipos de projeto por enquanto

    if @project.save
      render json: @project, status: :created, location: project_url(@project)
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    @project = Project.find(params[:id])

    if @project.update(project_params)
      head :no_content
    else
      render json: @project.errors, status: :unprocessable_entity
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy

    head :no_content
  end

  private

    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:name, :slug, :user_id, :description, :documentation_url, :code_url, :assets_url, 
        info_attributes: [:id, :board_id, :todo_list_id])
    end
end
