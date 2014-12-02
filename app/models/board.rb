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

  def load_story_map(project, param_sprint_id = nil)
    sprints = param_sprint_id ? load_sprint_or_backlog(param_sprint_id) : Sprint.current_sprints(self.id).includes(:version)
    stories = load_user_stories(project, sprints, param_sprint_id)
    statuses = StoryStatus.where(board_id: self.id).order(position: :asc)
    stories_hash = build_stories_hash(sprints, statuses, stories)
    sprints =  sprints.decorate unless sprints.is_a?(Array)
    return sprints, statuses, stories_hash
  end

  # Build a hash with the following struct :  {sprint_id: {status : [story, story], status : [story, story] }}
  # E.g : {1: {'To do' => [story, story], 'In progress' => [story, story]}}
  # @param [Array] sprints : an array of Sprint.
  # @param [Array] statuses : an array of StoryStatus.
  # @param [Array] stories : an array of UserStories
  def build_stories_hash(sprints, statuses, stories)
    sprints.inject({}) do |memo, sprint|
      memo[sprint.id] = build_status_stories_hash(sprint, statuses, stories)
      memo
    end
  end

  # Build a hash with the following struct :  {status : [story, story], status : [story, story] }
  # E.g : {To do' => [story, story], 'In progress' => [story, story]}
  # For the given sprint
  # @param [Sprint] sprint : the given sprint that stories belongs to.
  # @param [Array] statuses : an array of StoryStatus.
  # @param [Array] stories : an array of UserStories.
  def build_status_stories_hash(sprint, statuses, stories)
    statuses.inject({}) do |memo_status, status|
      memo_status[status.caption] = stories.select { |story| story.status_id.eql?(status.id) && story_included_in_sprint?(sprint, story) }
      memo_status
    end
  end

  # @param [Sprint] sprint
  # @param [Story] story
  # @return [Boolean] : does the story included in the given sprint?
  def story_included_in_sprint?(sprint, story)
    (story.sprint_id.eql?(sprint.id) || (story.sprint_id.nil? && sprint.id.eql?(-1)))
  end

  # This methods load a specific sprint, or backlog when sprint_id is -1.
  # @param [String] param_sprint_id : the given sprint_id to load specific sprint.
  def load_sprint_or_backlog(param_sprint_id)
    if param_sprint_id.eql?('-1')
      [Sprint.backlog(self.id)]
    else
      Sprint.where(id: param_sprint_id, board_id: self.id)
    end
  end

  # Load user stories for the given sprints. When param_sprint_id, user_story.sprint_id is nil it means that we
  # should load story from backlog.
  # @param [Project] project
  # @param [Array] sprints
  # @param [String] param_sprint_id
  def load_user_stories(project, sprints, param_sprint_id)
    sprint_id = param_sprint_id.eql?('-1') ? nil : sprints.collect(&:id)
    UserStory.where(board_id: self.id, sprint_id: sprint_id).includes(:tracker, :points).order(position: :asc).decorate(context: {project: project})
  end
end
