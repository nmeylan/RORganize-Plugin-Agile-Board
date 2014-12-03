// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function update_sprint_info(sprint_id, operator, points){
    update_sprint_story_points_counter(sprint_id, operator, points);
    update_sprint_stories_counter(sprint_id);
}

function update_sprint_story_points_counter(sprint_id, operator, points){
    var points = points;
    var sprint = $("#sprint-"+sprint_id);
    console.log(sprint);
    var story_points_counter = sprint.find(".counter.total-entries.points-counter");
    var story_points_counter_val = parseInt(story_points_counter.text());
    var new_value = operator == '+' ? story_points_counter_val + points :  story_points_counter_val - points;
    story_points_counter.text(story_points_counter.text().replace(/\d*/, new_value));
}

function update_sprint_stories_counter(sprint_id){
    var sprint = $("#sprint-"+sprint_id);
    var stories_count = sprint.find('.fancy-list-item.story').length;
    var stories_counter = sprint.find('.stories-counter');
    stories_counter.text(stories_counter.text().replace(/\d*/,stories_count));
}

