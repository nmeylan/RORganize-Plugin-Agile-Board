class UserStory < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  belongs_to :points, class_name: 'StoryPoint', foreign_key: :point_id
  belongs_to :status, class_name: 'StoryStatus'
  belongs_to :tracker
  belongs_to :category
  belongs_to :sprint
  belongs_to :epic
  belongs_to :board

  validates :tracker_id, :status_id, :board_id, :title, presence: true
  before_save :set_backlog_id

  def caption
    self.title
  end

  def get_sprint
    if self.sprint_id > 0
      Sprint.eager_load_user_stories.find_by_id(self.sprint_id)
    else
      Sprint.backlog(self.board_id)
    end
  end

  def set_backlog_id
    self.sprint = nil if self.sprint_id.eql? -1
  end
end
