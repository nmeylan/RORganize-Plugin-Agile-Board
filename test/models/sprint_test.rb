require '../test_helper'

class SprintTest < ActiveSupport::TestCase
  def setup
    User.current = User.find_by_id(1)
    @sprint = Sprint.find_by_id(1)
    @total_sprint_points = @sprint.total_points

  end

  def teardown

  end

  test 'sprint total points' do
    assert_equal(30, @total_sprint_points)
  end

  test 'sprint health scope change on update' do
    extra_story = UserStory.find_by_id(6)
    extra_story.sprint = @sprint
    assert_not_equal(@total_sprint_points + extra_story.value, @sprint.total_points)
    extra_story.save
    @sprint.reload
    assert_equal(@total_sprint_points + extra_story.value, @sprint.total_points)
    assert_equal(9, @sprint.scope_change)
  end

  test 'sprint health scope change on addition' do
    extra_story = UserStory.new(sprint_id: @sprint.id, point_id: 10, title: 'My story', status_id: 1, tracker_id: 1, board_id: @sprint.board_id)
    @sprint.reload
    assert_equal(@total_sprint_points + extra_story.value, @sprint.total_points)
    assert_equal(25, @sprint.scope_change)
  end
end
