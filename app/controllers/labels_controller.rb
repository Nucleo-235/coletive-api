class LabelsController < ApplicationController

  # GET /labels
  # GET /labels.json
  def index
    @labels = Label.all

    render json: @labels
  end
end
