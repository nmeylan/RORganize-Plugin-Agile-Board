# Author: Nicolas Meylan
# Date: 01.11.14
# Encoding: UTF-8
# File: agile_board_controller.rb

class AgileBoardController < ApplicationController
  before_action :set_board

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_board
    @board = Board.find_by_project_id(@project.id)
    @board_decorator = @board.decorate(context: {project: @project}) if @board
  end
end