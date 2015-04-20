# Author: Nicolas Meylan
# Date: 01.11.14
# Encoding: UTF-8
# File: agile_board_controller.rb

class AgileBoardController < ApplicationController
  before_action :set_board
  before_action :set_display_sessions
  protected
  def peek_enabled?
    false
  end
  def agile_board_form_callback(path, method, action = 'new')
    respond_to do |format|
      format.js { respond_to_js action: action, locals: {path: path, method: method} }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_board
    @board = Board.find_by_project_id(@project.id)
    @board_decorator = @board.decorate(context: {project: @project}) if @board
  end

  def set_display_sessions
    @sessions[:display_mode] = session[:boards] ? session[:boards][:display_mode] : session[:agile_board_reports][:display_mode]
  end
end
