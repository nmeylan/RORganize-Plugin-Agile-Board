class Sprint < ActiveRecord::Base
  include Rorganize::Models::SmartRecords
  has_many :stories, class_name: 'UserStory', dependent: :nullify
  belongs_to :version
  belongs_to :board
  scope :eager_load_user_stories, -> { includes(stories: [:status, :points, :tracker, :category, :epic]) }
  scope :ordered_sprints, ->(board_id) { where(board_id: board_id, is_archived: false).
      includes(:version).eager_load_user_stories.order(start_date: :desc) }
  scope :current_sprints, ->(board_id) { where(board_id: board_id).
      where('sprints.start_date <= ? AND (sprints.end_date >= ? OR sprints.end_date IS NULL)', Date.today, Date.today) }

  validates :start_date, presence: true
  validates :name, presence: true, length: {maximum: 255}
  validate :dates_constraints, :name_uniqueness, :archive_constraints


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

  def running?
    self.end_date.nil? || self.end_date >= Date.today
  end

  def is_backlog?
    self.id.eql?(-1)
  end

  # Build a backlog sprint.
  # @param [String|Fixnum] board_id
  def self.backlog(board_id)
    backlog = Sprint.empty_backlog(board_id)
    backlog.stories = UserStory.where(sprint_id: nil, board_id: board_id).includes(:status, :points, :tracker, :category, :epic, :issues)
    backlog
  end

  def self.empty_backlog(board_id)
    Sprint.new(id: -1, name: 'Backlog', board_id: board_id)
  end

  def issues
    Issue.where(user_story_id: self.stories.collect(&:id))
  end

  # Check if sprints name are uniq inside a same version.
  def name_uniqueness
    other_sprint = Sprint.where(version_id: self.version_id, name: self.name).where.not(id: self.id).count
    if other_sprint > 0
      errors.add(:name, 'must be uniq inside a same version.')
    end
  end

  # Archive a running sprint must be impossible
  def archive_constraints
    if is_archived_changed? && self.running?
      errors.add(:archive, 'a running sprint is not allowed.')
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

  def total_points
    self.stories.inject(0) { |count, story| count + story.value }
  end

  def points_distribution
    distribution_stats_by_status(self.total_points, & ->(story) { story.value })
  end

  def stories_distribution
    distribution_stats_by_status(self.stories.count, 1)
  end

  # Return the distribution of something by status.
  # @return [Hash] will this structure : {Status => [distribution, percent], Status => [distribution, percent]}
  # Key is a StoryStatus (a frozen complex object). Value is an array of size 2 [Numeric, Numeric].
  def distribution_stats_by_status(total, content_or_block = nil)
    hash = self.stories.sort_by(&:status_position).inject({}) do |memo, story|
      memo[story.status.freeze] ||= [0, 0]
      memo[story.status.freeze][0] += block_given? ? yield(story) : content_or_block
      memo
    end
    hash.each do |status, stats|
      if total > 0
        hash[status][1] = ((stats[0].to_f / total) * 100.0).truncate
      else
        hash.delete(status)
      end
    end
  end
end
