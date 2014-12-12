# Author: Nicolas Meylan
# Date: 12.12.14
# Encoding: UTF-8
# File: burndown.rb
module AgileBoard
  module SprintStatistics
    module ScopeChange
      # Calculate the sprint scope change as it :
      # Adding or removing a story from a sprint, after it has started is considered a change of scope. The percentage is calculated based on the story points.
      # For example, if you started a sprint it 50 story points and add an issue with 5 story points, the Sprint Health would show a 10% scope change.
      # If you add/remove stories that don't have estimates, the scope change will not be altered.
      def scope_change
        stories = load_scope_change_data
        total = total_points
        total > 0 ? percentage_calculation(stories.inject(0) { |count, story| count + story.value }, total) : 0
      end

      #
      def load_scope_change_data
        UserStory.joins(:journals).eager_load(journals: :details).
            where('(journals.action_type = ? AND user_stories.sprint_id = ?) OR (journals.action_type = ? AND'\
                    ' journal_details.property_key = ? AND' \
                    ' (journal_details.value = ? OR journal_details.old_value = ?))', 'created', self.id,
                  'updated', 'sprint_id', self.name, self.name).
            where('journals.created_at >= ? AND user_stories.board_id = ?', self.start_date, self.board_id).
            includes(:points).group('user_stories.id')
      end
    end
  end
end