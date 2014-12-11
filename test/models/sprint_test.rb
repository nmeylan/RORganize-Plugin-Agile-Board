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

  test 'sprint burndown values' do
    sprint = Sprint.new(name: 'Sprint burndown', start_date: '2014-12-01', end_date: '2014-12-10', board_id: 1)
    sprint.save

    us1 = UserStory.create(sprint_id: sprint.id, title: 'burndown 1', point_id: 5, status_id: 1, tracker_id: 1, author_id: 1, board_id: 1)
    us2 = UserStory.create(sprint_id: sprint.id, title: 'burndown 2', point_id: 5, status_id: 1, tracker_id: 1, author_id: 1, board_id: 1)
    us3 = UserStory.create(sprint_id: sprint.id, title: 'burndown 3', point_id: 4, status_id: 1, tracker_id: 1, author_id: 1, board_id: 1)
    us4 = UserStory.create(sprint_id: sprint.id, title: 'burndown 4', point_id: 4, status_id: 1, tracker_id: 1, author_id: 1, board_id: 1)
    us5 = UserStory.create(sprint_id: sprint.id, title: 'burndown 5', point_id: 4, status_id: 1, tracker_id: 1, author_id: 1, board_id: 1)
    us6 = UserStory.create(sprint_id: sprint.id, title: 'burndown 6', point_id: 3, status_id: 1, tracker_id: 1, author_id: 1, board_id: 1)
    us7 = UserStory.create(sprint_id: sprint.id, title: 'burndown 7', point_id: 3, status_id: 1, tracker_id: 1, author_id: 1, board_id: 1)
    us8 = UserStory.create(sprint_id: sprint.id, title: 'burndown 8', point_id: 3, status_id: 1, tracker_id: 1, author_id: 1, board_id: 1)
    us9 = UserStory.create(sprint_id: sprint.id, title: 'burndown 9', point_id: 2, status_id: 1, tracker_id: 1, author_id: 1, board_id: 1)
    us10 = UserStory.create(sprint_id: sprint.id, title: 'burndown 10', point_id: 2, status_id: 1, tracker_id: 1, author_id: 1, board_id: 1)
    us11 = UserStory.create(sprint_id: sprint.id, title: 'burndown 10', point_id: nil, status_id: 1, tracker_id: 1, author_id: 1, board_id: 1)

    sprint.reload
    assert_equal(35, sprint.total_points)

    j1 = Journal.create(journalizable_id: us1.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,2, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j2 = Journal.create(journalizable_id: us2.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,2, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j3 = Journal.create(journalizable_id: us3.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,3, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j4 = Journal.create(journalizable_id: us4.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,3, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j5 = Journal.create(journalizable_id: us5.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,3, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j6 = Journal.create(journalizable_id: us6.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,4, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j7 = Journal.create(journalizable_id: us3.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,5, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j8 = Journal.create(journalizable_id: us8.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,5, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j9 = Journal.create(journalizable_id: us9.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,5, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j10 = Journal.create(journalizable_id: us10.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,7, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j11 = Journal.create(journalizable_id: us7.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,7, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j12 = Journal.create(journalizable_id: us5.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,8, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j13 = Journal.create(journalizable_id: us11.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,9, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)
    j14 = Journal.create(journalizable_id: us7.id, journalizable_type: 'UserStory', created_at: Time.new(2014,12,9, 11,21,0, "+01:00"), action_type: 'updated', user_id: User.current, project_id: sprint.board.project_id)


    jd1 = JournalDetail.create(journal_id: j1.id, old_value: 'To do', value: 'Done', property_key: 'status_id', property: 'Status')
    jd2 = JournalDetail.create(journal_id: j2.id, old_value: 'To do', value: 'Done', property_key: 'status_id', property: 'Status')
    jd3 = JournalDetail.create(journal_id: j3.id, old_value: 'To do', value: 'Done', property_key: 'status_id', property: 'Status')
    jd4 = JournalDetail.create(journal_id: j4.id, old_value: 'In progress', value: 'Done', property_key: 'status_id', property: 'Status')
    jd5 = JournalDetail.create(journal_id: j5.id, old_value: 'To do', value: 'Done', property_key: 'status_id', property: 'Status')
    jd6 = JournalDetail.create(journal_id: j6.id, old_value: 'To do', value: 'Done', property_key: 'status_id', property: 'Status')
    jd7 = JournalDetail.create(journal_id: j7.id, old_value: 'Done', value: 'In progress', property_key: 'status_id', property: 'Status')
    jd8 = JournalDetail.create(journal_id: j8.id, old_value: 'To do', value: 'Done', property_key: 'status_id', property: 'Status')
    jd9 = JournalDetail.create(journal_id: j9.id, old_value: 'To do', value: 'Done', property_key: 'status_id', property: 'Status')
    jd10 = JournalDetail.create(journal_id: j10.id, old_value: 'To do', value: 'Done', property_key: 'status_id', property: 'Status')
    jd11 = JournalDetail.create(journal_id: j11.id, old_value: 'To do', value: 'Done', property_key: 'status_id', property: 'Status')
    jd12 = JournalDetail.create(journal_id: j12.id, old_value: 'Done', value: 'In progress', property_key: 'status_id', property: 'Status')
    jd13 = JournalDetail.create(journal_id: j13.id, old_value: 'In progress', value: 'Done', property_key: 'status_id', property: 'Status')
    jd14 = JournalDetail.create(journal_id: j14.id, old_value: 'Done', value: 'In progress', property_key: 'status_id', property: 'Status')

    expected_result = {
        '2014-12-01' => 35,
        '2014-12-02' => 35 - 10,
        '2014-12-03' => 25 - 12,
        '2014-12-04' => 13 - 3,
        '2014-12-05' => 10 + 4 - 3 - 2,
        '2014-12-06' => 9,
        '2014-12-07' => 9 - 3 -2,
        '2014-12-08' => 4 + 4,
        '2014-12-09' => 8 + 3,
        '2014-12-10' => 11,
    }
    assert_equal(expected_result, sprint.burndown_values)
  end
end
