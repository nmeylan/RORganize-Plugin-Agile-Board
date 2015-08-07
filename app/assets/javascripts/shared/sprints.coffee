@update_sprint_info = (sprint_id) ->
  update_sprint_story_points_counter(sprint_id)
  update_sprint_stories_counter(sprint_id)

@update_sprint_stories_counter = (sprint_id) ->
  sprint_id = if sprint_id.toString().indexOf('sprint-') > -1 then sprint_id else 'sprint-' + sprint_id
  sprint = $('#' + sprint_id)
  stories_count = sprint.find('.fancy-list-item.story:visible').length
  stories_counter = sprint.find('.stories-counter')
  stories_counter.text stories_counter.text().replace(/\d*/, stories_count)

@update_sprint_story_points_counter = (sprint_id) ->
  sprint_id = if sprint_id.toString().indexOf('sprint-') > -1 then sprint_id else 'sprint-' + sprint_id
  sprint = $('#' + sprint_id)
  story_points_counter = sprint.find('.fancy-list-item.story:visible').find('.story-points')
  new_value = 0
  story_points_counter.each ->
    `var story_points_counter`
    currentValue = $(this).text()
    currentValue = if currentValue == '-' then 0 else parseInt(currentValue)
    new_value += currentValue

  story_points_counter = sprint.find('.counter.total-entries.points-counter')
  story_points_counter.text story_points_counter.text().replace(/\d*/, new_value)
