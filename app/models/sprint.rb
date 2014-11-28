class Sprint < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  has_many :stories, class_name: 'UserStory', dependent: :nullify
  belongs_to :version
  belongs_to :board
  scope :eager_load_user_stories, -> { includes(stories: [:status, :points, :tracker, :category, :epic]) }
  scope :ordered_sprints, ->(board_id) { where(board_id: board_id).
      includes(:version).eager_load_user_stories.order(start_date: :desc) }
  scope :current_sprints, ->(board_id) { where(board_id: board_id).where('sprints.start_date <= ? AND (sprints.end_date >= ? OR sprints.end_date IS NULL)', Date.today, Date.today) }

  validates :start_date, presence: true
  validates :name, presence: true, length: { maximum: 255 }
  validate :dates_constraints, :name_uniqueness

  after_update :update_issues

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

  def is_backlog?
    self.id.eql?(-1)
  end

  # Build a backlog sprint.
  # @param [String|Fixnum] board_id
  def self.backlog(board_id)
    backlog = Sprint.new(id: -1, name: 'Backlog')
    backlog.stories = UserStory.where(sprint_id: nil, board_id: board_id).includes(:status, :points, :tracker, :category, :epic, :issues)
    backlog
  end

  def issues
    Issue.where(user_story_id: self.stories.collect(&:id))
  end

  def name_uniqueness
    other_sprint = Sprint.where(version_id: self.version_id, name: self.name).where.not(id: self.id).count
    if other_sprint > 0
      errors.add(:name, 'must be uniq inside a same version.')
    end
  end

  def update_issues
    issues_attributes = %w(version_id)
    issue_ids = self.issues.collect(&:id)
    project = self.board.project
    self.changes.each do |attr_name, values|
      if issues_attributes.include?(attr_name)
        value = values[1]
        Issue.bulk_edit(issue_ids, {attr_name => value}, project)
      end
    end
  end
end
