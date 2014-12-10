require '../test_helper'

class SprintTest < ActiveSupport::TestCase
  SPRINT_1_TOTAL_POINTS = 30
  def setup
    User.current = User.find_by_id(1)
    @sprint = Sprint.find_by_id(1)
    @total_sprint_points = @sprint.total_points

  end

  def teardown

  end

  test 'sprint total points' do
    sprint_total_points_checker
  end

  test 'sprint health scope change on update when sprint has started' do
    sprint_total_points_checker
    # Load a story that is not present in the Sprint 1
    extra_story = UserStory.find_by_id(6) # This story has 3 points
    # Put story to the sprint 1
    extra_story.sprint = @sprint
    extra_story.save
    @sprint.reload
    # Does total points is updated. Sprint should now have 33 points
    assert_equal(@total_sprint_points + extra_story.value, @sprint.total_points)
    # (3 / 33) * 100 = 9.
    assert_equal(9, @sprint.scope_change)


    # Put story back to the sprint 2
    extra_story.sprint = Sprint.find_by_id(2)
    extra_story.save
    @sprint.reload
    # Does total points is updated. Sprint should now have 30 points.
    assert_equal(@total_sprint_points, @sprint.total_points)
    # (3 / 30) * 100 = 10.
    assert_equal(10, @sprint.scope_change)
  end

  test 'sprint health scope change on addition' do
    sprint_total_points_checker
    # Create a story with 10 points.
    sprint_change_trigger
  end

  test 'scope change same sprint name different board' do
    sprint_total_points_checker

    sprint_3 = Sprint.find_by_id(3)
    extra_story = UserStory.new(sprint_id: nil, point_id: 10, title: 'My story', status_id: 1, tracker_id: 1, board_id: sprint_3.board_id)
    extra_story.save
    sprint_3.reload
    assert_equal(0, sprint_3.scope_change)

    extra_story.sprint = sprint_3
    extra_story.save
    sprint_3.reload
    assert_equal(100, sprint_3.scope_change)

    # Perform a sprint change on a sprint of an other board.
    sprint_change_trigger

  end

  test 'sprint health work complete' do
    sprint_total_points_checker
    assert_equal(7, UserStory.where(status_id: 2).inject(0){|sum, story| sum + story.value})
    assert_equal(23, @sprint.work_complete_calculation)
  end

  def sprint_total_points_checker
    # Sprint has 30 points
    assert_equal(SPRINT_1_TOTAL_POINTS, @total_sprint_points)
  end


  def sprint_change_trigger
    extra_story = UserStory.new(sprint_id: @sprint.id, point_id: 10, title: 'My story', status_id: 1, tracker_id: 1, board_id: @sprint.board_id)
    extra_story.save
    @sprint.reload
    # Does total points is updated. Sprint should now have 40 points.
    assert_equal(@total_sprint_points + extra_story.value, @sprint.total_points)
    # (10 / 40) * 100 = 25
    assert_equal(25, @sprint.scope_change)

    # Put story to the sprint 2
    extra_story.sprint = Sprint.find_by_id(2)
    extra_story.save
    @sprint.reload
    # Does total points is updated. Sprint should now have 30 points.
    assert_equal(@total_sprint_points, @sprint.total_points)
    # (10 / 30) * 100 = 33.
    assert_equal(33, @sprint.scope_change)
  end
end
