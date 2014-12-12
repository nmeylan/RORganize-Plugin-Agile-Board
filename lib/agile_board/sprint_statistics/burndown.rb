# Author: Nicolas Meylan
# Date: 12.12.14
# Encoding: UTF-8
# File: burndown.rb
module AgileBoard
  module SprintStatistics
    module Burndown

      # Burndown values calculation.
      # @return [Hash] a hash with the following structure :
      # {Date => {stories: {story_id(Numeric): {variation: Numeric, object: String}}, sum: Numeric}}
      # E.g {
      #   '2014-12-01' => {stories: {}, sum: 31},
      #   '2014-12-02' => {stories: {1 => {object: "Feature #1", variation: -1},
      #                             2 => {object: "Bug #2", variation: -5}
      # }
      def burndown_values
        @done_status = self.board.done_status.name.freeze
        end_date = self.end_date && self.end_date <= Date.today ? self.end_date : Date.today
        date_range = self.start_date.to_date..end_date.to_date
        journals = load_burndown_data(end_date)
        build_burndown_hash(date_range, journals)
      end

      # @param [Range] date_range : the range for the burndown calculation :
      # Start date is the sprint start date
      # End date is the is the sprint end date, but if end date is nil or > Today then end date is Today.
      # @param [Array] journals
      def build_burndown_hash(date_range, journals)
        date_range.inject({}) do |memo, date|
          memo[date.to_formatted_s] = remaining_points_at(journals.select { |journal| journal.created_at.to_date.eql?(date) })
          memo[date.to_formatted_s][:sum] += memo[(date - 1).to_formatted_s] ? memo[(date - 1).to_formatted_s][:sum] : total_points
          memo
        end
      end

      # Load all journals for user stories status changes for a given date range.
      # Eager load journal details, user stories (and their points and tracker)
      # @param [Date] end_date : default it is the sprint end date,
      # but if end date is nil or > Today then end date is Today.
      def load_burndown_data(end_date)
        Journal.joins(:details).
            where(journalizable_id: self.stories.collect(&:id), journalizable_type: 'UserStory', action_type: 'updated').
            where('DATE(journals.created_at) >= ? AND DATE(journals.created_at) <= ?', self.start_date, end_date).
            where('journal_details.property_key = ?', 'status_id').preload(:details, journalizable: [:points, :tracker])
      end

      # Calculate remaining points at a given date (collection of journals at this date)
      # @param [Array] journals (collection of journals at a given date).
      # @return [Hash] a hash with the following structure :
      # {stories: {story_id(Numeric): {variation: Numeric, object: String}}, sum: Numeric}
      # E.g {
      #   stories: {1 => {object: "Feature #1", variation: -1}, 2 => {object: "Bug #2", variation: -5}
      # }
      def remaining_points_at(journals)
        journals.inject({stories: {}, sum: 0}) do |memo, journal|
          story = journal.journalizable.freeze
          variation = journal_points_variation_calculation(journal, story)
          unless variation == 0
            memo[:stories][story.id] ||= {object: "#{story.tracker.caption} ##{story.id}"}
            memo[:stories][story.id][:variation] ||= 0
            memo[:stories][story.id][:variation] += variation
          end
          memo[:sum] += variation
          memo
        end
      end

      # @param [Journal] journal : a journal.
      # @param [UserStory] story : the user story linked to the journal.
      # @return [Numeric] the variation for the sprint caused by the story status change.
      # E.g : if story has 5 points and new status is the board "Done" status then the variation would be -5.
      # if story has 5 points and old status is the board "Done" status then the variation would be +5.
      def journal_points_variation_calculation(journal, story)
        journal.details.inject(0) do |sum, detail|
          if detail.value.eql?(@done_status)
            sum - story.value
          elsif detail.old_value.eql?(@done_status)
            sum + story.value
          else
            sum
          end
        end
      end
    end
  end
end