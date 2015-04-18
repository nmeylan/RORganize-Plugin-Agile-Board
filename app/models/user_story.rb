class UserStory < ActiveRecord::Base
  include SmartRecords
  include Journalizable
  include Commentable
  include Notifiable
  include Watchable
  include AgileBoard::Models::StoryChangePositionLogic

  exclude_attributes_from_journal(:description)

  Issue.belongs_to :user_story, counter_cache: true

  belongs_to :points, class_name: 'StoryPoint', foreign_key: :point_id
  belongs_to :status, class_name: 'StoryStatus'
  belongs_to :tracker
  belongs_to :category
  belongs_to :sprint
  belongs_to :epic
  has_many :issues, dependent: :nullify
  belongs_to :author, class_name: 'User'
  belongs_to :board
  belongs_to :project

  scope :fetch_dependencies, -> { includes(:status, :points, :tracker, :category, sprint: :version) }
  scope :fetch_issues_dependencies, -> { includes(issues: [:tracker, :category, :version, :assigned_to, status: :enumeration]) }

  validates :tracker_id, :status_id, :board_id, presence: true
  validates :title, presence: true, length: {maximum: 255}

  before_save :set_backlog_id
  before_create :update_position, :populate_sequence_id
  after_update :update_issues
  after_destroy :dec_position_on_destroy

  def populate_sequence_id
    sequence_name = "#{self.class.table_name}_sequence".to_sym
    board.update_column(sequence_name, board.send(sequence_name) + 1)
    self.sequence_id = board.send(sequence_name)
  end

  def to_param
    self.sequence_id.to_s
  end

  def caption
    self.title
  end

  def project
    self.board.project
  end
  def project_id
    self.board.project_id
  end

  def get_sprint(fetch_dependencies = false)
    if self.sprint_id && self.sprint_id > 0
      fetch_dependencies ? Sprint.eager_load_user_stories.find_by_id(self.sprint_id) : self.sprint
    else
      fetch_dependencies ? Sprint.backlog(self.board_id) : Sprint.new(id: -1, name: 'Backlog')
    end
  end

  def value
    self.points ? self.points.value : 0
  end

  def status_position
    self.status.position
  end

  def archived?
    self.sprint && self.sprint.archived?
  end

  def tasks_version_id
    version = self.get_sprint.version
    version ? version.id : nil
  end

  def tasks_status_id
    status = self.status.issues_status
    status ? status.id : nil
  end

  def set_backlog_id
    self.sprint = nil if self.sprint_id.eql? -1
  end

  def update_issues
    issue_ids = self.issues.collect(&:sequence_id).to_a
    project = self.board.project
    update_issues_on_sprint_change(issue_ids, project) if issue_ids.any?
    update_issues_on_story_change(issue_ids, project) if issue_ids.any?
  end

  def update_issues_on_sprint_change(issue_ids, project)
    if self.changes.keys.include?('sprint_id')
      new_sprint = Sprint.find_by_id(self.changes['sprint_id'])
      Issue.bulk_edit(issue_ids, {version_id: new_sprint.version_id}, project)
    end
  end

  def update_issues_on_story_change(issue_ids, project)
    issues_attributes = %w(tracker_id category_id status_id)
    self.changes.each do |attr_name, values|
      if issues_attributes.include?(attr_name)
        value = values[1]
        if attr_name.eql?('status_id')
          value = StoryStatus.find(value).issues_status_id
        end
        Issue.bulk_edit(issue_ids, {attr_name.to_sym => value}, project)
      end
    end
  end



  def detach_tasks(ids)
    issues_to_remove = self.issues.collect { |issue| issue if ids.include?(issue.sequence_id.to_s) }.compact
    self.issues.delete(issues_to_remove)
    self.save
  end


  # @param [String] values : is a text that contains issues id.
  # #34445 #666644. But we have to check that given id represent issues that are
  # contains in the current project.
  # We should also exclude trash data.
  def attach_tasks(values)
    project = self.board.project_id
    ids = values.split(/\s/).collect{|chunk| chunk.tr('#', '') if chunk.match(/#\d*/)}.compact
    issues = Issue.where(project_id: project, sequence_id: ids, user_story_id: nil)
    count = issues.size
    issues.update_all(user_story_id: self.id)
    UserStory.update_counters(self.id, issues_count: count)

  end

end
