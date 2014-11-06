class UserStory < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  belongs_to :points, class_name: 'StoryPoint', foreign_key: :point_id
  belongs_to :status, class_name: 'StoryStatus'
  belongs_to :tracker
  belongs_to :category
  belongs_to :sprint
  belongs_to :epic
  belongs_to :author, class_name: 'User'
  belongs_to :board

  scope :fetch_dependencies, -> { includes(:status, :points, :tracker, :category, sprint: :version)}

  validates :tracker_id, :status_id, :board_id, :title, presence: true
  before_save :set_backlog_id

  def caption
    self.title
  end

  def get_sprint
    if self.sprint_id
      self.sprint
    else
      Sprint.new(id: -1, name: 'Backlog')
    end
  end

  def set_backlog_id
    self.sprint = nil if self.sprint_id.eql? -1
  end
end
