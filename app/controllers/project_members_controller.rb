class ProjectMembersController < ApplicationController
  before_action :set_project_member, only: [:show, :update, :destroy]

  # GET /project_members
  # GET /project_members.json
  def index
    @project_members = ProjectMember.all

    render json: @project_members
  end

  # GET /project_members/1
  # GET /project_members/1.json
  def show
    render json: @project_member
  end

  # POST /project_members
  # POST /project_members.json
  def create
    @project_member = ProjectMember.new(project_member_params)

    if @project_member.save
      render json: @project_member, status: :created, location: @project_member
    else
      render json: @project_member.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /project_members/1
  # PATCH/PUT /project_members/1.json
  def update
    @project_member = ProjectMember.find(params[:id])

    if @project_member.update(project_member_params)
      head :no_content
    else
      render json: @project_member.errors, status: :unprocessable_entity
    end
  end

  # DELETE /project_members/1
  # DELETE /project_members/1.json
  def destroy
    @project_member.destroy

    head :no_content
  end

  private

    def set_project_member
      @project_member = ProjectMember.find(params[:id])
    end

    def project_member_params
      params.require(:project_member).permit(:project_id, :user_id, :type, :trello_member_id)
    end
end
