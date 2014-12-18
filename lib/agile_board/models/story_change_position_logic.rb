# Author: Nicolas Meylan
# Date: 18.12.14
# Encoding: UTF-8
# File: change_position_logic.rb
module AgileBoard
  module Models
    module StoryChangePositionLogic
      def update_position
        board = self.board
        count_stories = board.user_stories.where(sprint_id: self.sprint_id).count
        self.position = count_stories + 1
      end

      # Set the position of the current user story between the given previous and next stories.
      # @param [String] prev_id : previous user story id.
      # @param [String] next_id : next user story id.
      def change_position(prev_id, next_id)
        old_position = self.position
        prev_or_next_story = prev_id ? UserStory.find_by_id(prev_id) : UserStory.find_by_id(next_id)
        if self.sprint_id_changed? # When the sprint changed we should apply a different reorder strategy.
          change_position_on_sprint_change(old_position, prev_id, prev_or_next_story)
        else
          change_position_on_reorder(old_position, prev_id, prev_or_next_story)
        end
      end

      # @param [Numeric] old_position : the story position before we reorder it.
      # @param [String] prev_id :  previous user story id.
      # @param [Object] prev_or_next_story : the new neighbor for the current story.
      # In most cases it is the previous story, but when we put the current story on the
      # top of the list, previous is nil so we load the next.
      def change_position_on_reorder(old_position, prev_id, prev_or_next_story)
        if prev_or_next_story #Can be nil when the list is empty. Happening whe we reorder from the story map.
          self.position = prev_or_next_story.position
          if prev_or_next_story.position > old_position
            # Decrement position for all stories that were between the old and the new position.
            decrement_position_on_reorder(old_position)
          else
            self.position += 1 unless prev_id.nil?
            # Increment position for all stories that were between the old and the new position.
            increment_position_on_reorder(old_position)
          end
        end
      end

      # Decrement position for all stories that were between the old and the new position.
      # @param [Numeric] old_position : the story position before we reorder it.
      def decrement_position_on_reorder(old_position)
        UserStory
            .where('position > ? AND position <= ? AND id <> ?', old_position, self.position, self.id)
            .where(sprint_id: self.sprint_id, board_id: self.board_id).update_all('position = position - 1')
      end

      # Increment position for all stories that were between the old and the new position.
      # @param [Numeric] old_position : the story position before we reorder it.
      def increment_position_on_reorder(old_position)
        UserStory
            .where('position >= ? AND position < ? AND id <> ?', self.position, old_position, self.id)
            .where(sprint_id: self.sprint_id, board_id: self.board_id).update_all('position = position + 1')
      end

      # @param [Numeric] old_position : the story position before we reorder it.
      # @param [String] prev_id :  previous user story id.
      # @param [Object] prev_or_next_story : the new neighbor for the current story.
      # In most cases it is the previous story, but when we put the current story on the
      # top of the list, previous is nil so we load the next.
      def change_position_on_sprint_change(old_position, prev_id, prev_or_next_story)
        old_sprint_id = self.sprint_id_change.first # get the old sprint id.
        if prev_or_next_story #Can be nil when the list is empty.
          self.position = prev_id ? prev_or_next_story.position + 1 : prev_or_next_story.position
          # Increment position for all next stories in the new sprint.
          increment_position_on_sprint_change
        else
          self.position = 1
        end
        # Decrement position for old sprint's stories
        decrement_position_on_sprint_change(old_position, old_sprint_id)
      end

      # Decrement position for old sprint's stories
      # @param [Numeric] old_position : the story position before we reorder it.
      # @param [Numeric] old_sprint_id : the id of the old story sprint.
      def decrement_position_on_sprint_change(old_position, old_sprint_id)
        UserStory.where('position > ? AND id <> ?', old_position, self.id)
            .where(sprint_id: old_sprint_id, board_id: self.board_id).update_all('position = position - 1')
      end

      # Increment position for all next stories in the new sprint.
      def increment_position_on_sprint_change
        UserStory
            .where('position >= ? AND id <> ?', self.position, self.id)
            .where(sprint_id: self.sprint_id, board_id: self.board_id).update_all('position = position + 1')
      end

      def dec_position_on_destroy
        position = self.position
        UserStory.where("position > ?", position).where(sprint_id: self.sprint_id, board_id: self.board_id).update_all('position = position - 1')
      end
    end
  end
end