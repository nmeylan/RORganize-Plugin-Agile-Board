class Board < ActiveRecord::Base
  Project.has_one :board, dependent: :destroy
  belongs_to :project
  has_many :story_points, dependent: :destroy
  has_many :story_statuses, dependent: :destroy
  has_many :user_stories, dependent: :destroy
  has_many :epics, dependent: :destroy
  has_many :sprint, dependent: :destroy
  after_create :set_board_default_configuration

  def set_board_default_configuration
    points = [1, 2, 3, 4, 5]
    statuses = {'To Do' => IssuesStatus.find_by_name('New').id,
                'In Progress' => IssuesStatus.find_by_name('In progress').id,
                'In Review' => IssuesStatus.find_by_name('Fixed to test').id,
                'Done' => IssuesStatus.find_by_name('Tested to be delivered').id}
    colors = ['#6cc644', '#fbca04', '#207de5', '#bd2c00']
    points.each { |point| StoryPoint.create(value: point, board_id: self.id) }
    i = 0
    statuses.each do |status, issues_status_id|
      StoryStatus.create(name: status, board_id: self.id, position: i, color: colors[i], issues_status_id: issues_status_id)
      i += 1
    end
  end


  def add_points(params)
    points_param = params.split(',').uniq
    points_param.each do |value|
      self.story_points << StoryPoint.new(value: value)
    end
    self.save
  end
end
