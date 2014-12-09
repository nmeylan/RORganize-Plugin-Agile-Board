# Author: Nicolas Meylan
# Date: 07.12.14
# Encoding: UTF-8
# File: sprint_statistics_calculator.rb
module AgileBoard
  module SprintStatisticsCalculator


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
      distribution_stats_add_percentage_calculation(hash, total)
    end

    # @param [Hash] hash : {Status => [distribution, 0], Status => [distribution, 0]}
    # @param [Numeric] total : the total to perform the percentage,
    # can be number of stories or sum of story points.
    def distribution_stats_add_percentage_calculation(hash, total)
      hash.each do |status, stats|
        if total > 0
          hash[status][1] = percentage_calculation(stats[0], total)
        else
          hash.delete(status)
        end
      end
    end


    # Calculate time elapse since the beginning of the sprint.
    # If sprint has no end_date then return days elapsed instead of a percentage.
    # @return [Numeric, Symbol] time_elapsed, unit(percent or days).
    def time_elapsed_calculation
      today = Date.today
      consumed_days = (today - self.start_date).to_i
      if self.end_date && self.end_date > today
        duration = (self.end_date - self.start_date).to_i
        return (consumed_days > 0 ? percentage_calculation(consumed_days, duration) : 0).round(1), :percent
      elsif self.end_date && self.end_date <= today
        return 100, :percent
      else
        return consumed_days > 0 ? consumed_days : 0, :days
      end
    end

    # Calculate work complete percentage based on number of stories points with the "Done" status.
    # @return [Numeric] percent of stories with the "Done" status.
    # Done status is the last one.
    def work_complete_calculation
      done_status_id = self.board.done_status.id
      done_stories = self.stories.select { |story| story.status_id.eql?(done_status_id) }
      done_stories_value = done_stories.inject(0) { |count, story| count + story.value }
      total = self.stories.inject(0) { |count, story| count + story.value }
      (total > 0 ? percentage_calculation(done_stories_value, total) : 0).truncate
    end

    def tasks_count
      self.stories.inject(0) { |count, story| count + story.issues.size }
    end

    # @return [Numeric] the percentage of tasks, contained by stories, progress.
    def tasks_progress
      total_done = 0
      total_tasks = 0
      self.stories.each do |story|
        story.issues.each do |issue|
          total_tasks += 1
          total_done += issue.done
        end
      end
      total_tasks > 0 ? total_done / total_tasks : 100
    end

    def scope_change
      stories = UserStory.joins(:journals).eager_load(journals: :details).
          where('(journals.action_type = ? AND user_stories.sprint_id = ?) OR (journals.action_type = ? AND'\
                    ' journal_details.property_key = ? AND' \
                    ' (journal_details.value = ? OR journal_details.old_value = ?))', 'created', self.id,
                'updated', 'sprint_id', self.name, self.name).
          where('journals.created_at >= ? AND user_stories.board_id = ?', self.start_date, self.board_id).
          includes(:points).group('user_stories.id')
      total = total_points
      total > 0 ? percentage_calculation(stories.inject(0) { |count, story| count + story.value }, total) : 0
    end


    def percentage_calculation(numerator, total)
      ((numerator.to_f / total) * 100.0).truncate
    end
  end
end