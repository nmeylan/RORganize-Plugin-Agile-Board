class Sprint < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  has_many :stories, class_name: 'UserStory', dependent: :nullify
  belongs_to :version
  belongs_to :board
  scope :eager_load_user_stories, -> { includes(stories: [:status, :points, :tracker, :category])}
  scope :ordered_sprints, ->(board_id) { where(board_id: board_id).includes(:version, ).eager_load_user_stories.order(start_date: :desc) }

  validates :name, :start_date, presence: true
  validate :dates_constraints, :name_uniqueness

  def caption
    self.name
  end

  def count_points
    self.stories.inject(0) { |sum, story| sum + (story.points ? story.points.value : 0) }
  end

  def dates_constraints
    if self.end_date && self.start_date > self.end_date
      errors.add(:end_date, 'must be superior than start date.')
    end
  end

  def self.backlog(board_id)
    backlog = Sprint.new(id: -1, name: 'Backlog')
    backlog.stories = UserStory.where(sprint_id: nil, board_id: board_id).includes(:status, :points, :tracker, :category)
    backlog
  end

  def name_uniqueness
    other_sprint = Sprint.where(version_id: self.version_id, name: self.name).where.not(id: self.id).count
    if other_sprint > 0
      errors.add(:name, 'must be uniq inside a same version.')
    end
  end
end
