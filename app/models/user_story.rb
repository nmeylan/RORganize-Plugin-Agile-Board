class UserStory < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  belongs_to :points, class_name: 'StoryPoint', foreign_key: :point_id
  belongs_to :status, class_name: 'StoryStatus'
  belongs_to :tracker
  belongs_to :category
  belongs_to :sprint
  belongs_to :epic
  has_many :issues
  belongs_to :author, class_name: 'User'
  belongs_to :board

  scope :fetch_dependencies, -> { includes(:status, :points, :tracker, :category, sprint: :version)}

  validates :tracker_id, :status_id, :board_id, :title, presence: true
  before_save :set_backlog_id

  def caption
    self.title
  end

  def get_sprint(fetch_dependencies = false)
    if self.sprint_id && self.sprint_id > 0
      fetch_dependencies ? Sprint.eager_load_user_stories.find_by_id(self.sprint_id) : self.sprint
    else
      fetch_dependencies ? Sprint.backlog(self.board_id) : Sprint.new(id: -1, name: 'Backlog')
    end
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
end
