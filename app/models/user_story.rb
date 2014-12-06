class UserStory < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  include Rorganize::Models::Journalizable
  include Rorganize::Models::Commentable
  include Rorganize::Models::Notifiable
  include Rorganize::Models::Watchable

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

  scope :fetch_dependencies, -> { includes(:status, :points, :tracker, :category, sprint: :version) }
  scope :fetch_issues_dependencies, -> { includes(issues: [:tracker, :category, :version, :assigned_to, status: :enumeration]) }

  validates :tracker_id, :status_id, :board_id, presence: true
  validates :title, presence: true, length: {maximum: 255}

  before_save :set_backlog_id
  before_create :update_position
  after_update :update_issues
  after_destroy :dec_position_on_destroy

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
    issue_ids = self.issues.collect(&:id).to_a
    project = self.board.project
    update_issues_on_sprint_change(issue_ids, project)
    update_issues_on_story_change(issue_ids, project)
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
        Issue.bulk_edit(issue_ids, {attr_name => value}, project)
      end
    end
  end

  def update_position
    board = self.board
    count_stories = board.user_stories.where(sprint_id: self.sprint_id).count
    self.position = count_stories + 1
  end

  # Set the position of the current user story between the given previous and next stories.
  # @param [String] prev_id : previous user story id.
  # @param [String] next_id : next user story id.
  def change_position(prev_id, next_id)
    old_position = self.position
    prev_or_next_story = prev_id ? UserStory.find_by_id(prev_id) : UserStory.find_by_id(next_id)
    if self.sprint_id_changed? # When the sprint changed we should apply a different reorder strategy.
      change_position_on_sprint_change(old_position, prev_id, prev_or_next_story)
    else
      change_position_on_reorder(old_position, prev_id, prev_or_next_story)
    end
  end

  # @param [Numeric] old_position : the story position before we reorder it.
  # @param [String] prev_id :  previous user story id.
  # @param [Object] prev_or_next_story : the new neighbor for the current story.
  # In most cases it is the previous story, but when we put the current story on the
  # top of the list, previous is nil so we load the next.
  def change_position_on_reorder(old_position, prev_id, prev_or_next_story)
    if prev_or_next_story #Can be nil when the list is empty. Happening whe we reorder from the story map.
      self.position = prev_or_next_story.position
      if prev_or_next_story.position > old_position
        # Decrement position for all stories that were between the old and the new position.
        UserStory
        .where('position > ? AND position <= ? AND id <> ?', old_position, self.position, self.id)
        .where(sprint_id: self.sprint_id, board_id: self.board_id).update_all('position = position - 1')
      else
        self.position += 1 unless prev_id.nil?
        # Increment position for all stories that were between the old and the new position.
        UserStory
        .where('position >= ? AND position < ? AND id <> ?', self.position, old_position, self.id)
        .where(sprint_id: self.sprint_id, board_id: self.board_id).update_all('position = position + 1')
      end
    end
  end

  # @param [Numeric] old_position : the story position before we reorder it.
  # @param [String] prev_id :  previous user story id.
  # @param [Object] prev_or_next_story : the new neighbor for the current story.
  # In most cases it is the previous story, but when we put the current story on the
  # top of the list, previous is nil so we load the next.
  def change_position_on_sprint_change(old_position, prev_id, prev_or_next_story)
    old_sprint_id = self.sprint_id_change.first # get the old sprint id.
    if prev_or_next_story #Can be nil when the list is empty.
      self.position = prev_id ? prev_or_next_story.position + 1 : prev_or_next_story.position
      # Increment position for all next stories in the new sprint.
      UserStory
      .where('position >= ? AND id <> ?', self.position, self.id)
      .where(sprint_id: self.sprint_id, board_id: self.board_id).update_all('position = position + 1')
    else
      self.position = 1
    end
    # Decrement position for old sprint's stories
    UserStory.where('position > ? AND id <> ?', old_position, self.id)
    .where(sprint_id: old_sprint_id, board_id: self.board_id).update_all('position = position - 1')
  end

  def dec_position_on_destroy
    position = self.position
    UserStory.where("position > ?", position).where(sprint_id: self.sprint_id, board_id: self.board_id).update_all('position = position - 1')
  end

  def detach_tasks(ids)
    issues_to_remove = self.issues.collect { |issue| issue if ids.include?(issue.id.to_s) }.compact
    self.issues.delete(issues_to_remove)
    self.save
  end

end
