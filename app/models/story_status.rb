class StoryStatus < ActiveRecord::Base
  include SmartRecords
  belongs_to :board
  belongs_to :issues_status
  before_create :set_position
  validates :name, :board_id, :issues_status_id, presence: true
  validates :name, length: { maximum: 255 }

  def caption
    self.name
  end

  def set_position
    self.position = Board.find(self.board_id).story_statuses.count
  end

  def self.update_positions(project_id, ids)
    board = Board.find_by_project_id(project_id)
    board.story_statuses.each do |status|
      status.position = ids.index(status.id.to_s)
      status.save
    end
  end
end
