# Author: Nicolas Meylan
# Date: 01.11.14
# Encoding: UTF-8
# File: agile_board_controller.rb

class AgileBoardController < ApplicationController
  before_action :set_board

  protected

  def agile_board_form_callback(path, method)
    respond_to do |format|
      format.js { respond_to_js action: 'new', locals: {path: path, method: method} }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_board
    @board = Board.find_by_project_id(@project.id)
    @board_decorator = @board.decorate(context: {project: @project}) if @board
  end
end