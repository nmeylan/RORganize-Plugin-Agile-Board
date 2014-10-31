class Board < ActiveRecord::Base
  Project.has_one :board, dependent: :destroy
  has_one :project
  has_many :story_points, dependent: :destroy
  has_many :story_statuses, dependent: :destroy
  has_many :user_stories, dependent: :destroy
  has_many :epics, dependent: :destroy
  has_many :sprint, dependent: :destroy
  after_create :set_board_default_configuration

  def set_board_default_configuration
    points = [1, 2, 3, 4, 5]
    statuses = ['To Do', 'In Progress', 'In Review', 'Done']
    points.each { |point| StoryPoint.create(value: point, board_id: self.id) }
    i = 0
    statuses.each { |status| StoryStatus.create(name: status, board_id: self.id, position: i); i += 1 }
  end


  def add_points(params)
    points_param = params.split(',').uniq
    points_param.each do |value|
      self.story_points << StoryPoint.new(value: value)
    end
    self.save
  end
end
