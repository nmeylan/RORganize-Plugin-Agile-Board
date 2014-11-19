class Board < ActiveRecord::Base
  Project.has_one :board, dependent: :destroy
  belongs_to :project
  has_many :story_points, dependent: :destroy
  has_many :story_statuses, dependent: :destroy
  has_many :user_stories, dependent: :destroy
  has_many :epics, dependent: :destroy
  has_many :sprint, dependent: :destroy
  after_create :set_board_default_configuration

  validates :project_id, uniqueness: true

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

  def load_story_map(project, sprint_id = nil)
    sprints = sprint_id ? Sprint.where(id: sprint_id, board_id: self.id).to_a : Sprint.current_sprints(self.id).includes(:version)
    stories = UserStory.where(board_id: self.id, sprint_id: sprints.collect(&:id)).includes(:tracker).order(position: :asc).decorate(context: {project: project})
    statuses = StoryStatus.where(board_id: self.id).order(position: :asc)
    stories_hash = sprints.inject({}) do |memo, sprint|
      memo[sprint.id] = statuses.inject({}) do |memo_status, status|
        memo_status[status.caption] = stories.select{ |story| story.status_id.eql?(status.id) && story.sprint_id.eql?(sprint.id)}
        memo_status
      end
      memo
    end
    return sprints, statuses, stories_hash
  end
end
