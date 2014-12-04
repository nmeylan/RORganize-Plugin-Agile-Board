// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function update_sprint_info(sprint_id) {
    update_sprint_story_points_counter(sprint_id);
    update_sprint_stories_counter(sprint_id);
}

function update_sprint_stories_counter(sprint_id) {
    sprint_id = (sprint_id.toString().indexOf('sprint-') > -1) ? sprint_id : "sprint-" + sprint_id;
    var sprint = $('#' + sprint_id);
    var stories_count = sprint.find('.fancy-list-item.story:visible').length;
    var stories_counter = sprint.find('.stories-counter');
    stories_counter.text(stories_counter.text().replace(/\d*/, stories_count));
}


function update_sprint_story_points_counter(sprint_id) {
    sprint_id = (sprint_id.toString().indexOf('sprint-') > -1) ? sprint_id : "sprint-" + sprint_id;
    var sprint = $('#' + sprint_id);
    var story_points_counter = sprint.find('.fancy-list-item.story:visible').find('.story-points');
    var new_value = 0;
    story_points_counter.each(function () {
        var currentValue = $(this).text();
        currentValue = currentValue === '-' ? 0 : parseInt(currentValue);
        new_value += currentValue;
    });
    var story_points_counter = sprint.find(".counter.total-entries.points-counter");
    story_points_counter.text(story_points_counter.text().replace(/\d*/, new_value));
}
