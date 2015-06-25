// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function (e) {
    if (gon.controller === "boards") {
        initialize_board();
        bind_user_story_search_field();
    }else if(gon.controller === 'agile_board_reports'){
        bind_agile_board_reports();
    }
});

function initialize_board() {
    bind_stories_sortable();
    bind_story_map_sortable();
    jQuery(".story-statuses-list.sortable").sortable({
        update: function (event, ui) {
            var el = $(this);
            var url = el.data('link');
            var ids = el.find('.fancy-list-item');
            var values = [];
            ids.each(function (e) {
                values.push($(this).attr('id').split('-')[1]);
            });

            jQuery.ajax({
                url: url,
                type: 'post',
                dataType: 'script',
                data: {ids: values}
            });

        }
    });
}
function bind_story_map_sortable() {
    jQuery(".story-map-stories.sortable").sortable(sortable_story_map_hash());
}
function bind_stories_sortable() {
    jQuery(".stories-list.sortable").sortable(sortable_stories_hash());
}

function sortable_story_map_hash() {
    var self = this;
    return {
        connectWith: 'ul',
        placeholder: "ui-state-highlight",
        update: function (event, ui) {
            var el = ui.item;
            var status = $(el.parents(".status"));
            var status_id = status.attr('id').replace('status-', '');
            var next_prev_id = self.next_prev_id(el);
            if (this !== ui.item.parent()[0]) {
                jQuery.ajax({
                    url: el.data('link'),
                    type: 'post',
                    dataType: 'script',
                    data: {status_id: status_id, prev_id: next_prev_id[0], next_id: next_prev_id[1]}
                });
            }
        }
    };
}
function sortable_stories_hash() {
    var self = this;
    return {
        connectWith: 'ul',
        placeholder: "ui-state-highlight",
        update: function (event, ui) {
            var el = ui.item;
            var sprint = $(el.parents(".sprint")[1]);
            var sprint_id = sprint.attr('id').replace('sprint-', '');
            var next_prev_id = self.next_prev_id(el);
            if (this === ui.item.parent()[0]) {
                jQuery.ajax({
                    url: el.data('link'),
                    type: 'post',
                    dataType: 'script',
                    data: {sprint_id: sprint_id, prev_id: next_prev_id[0], next_id: next_prev_id[1]}
                });
            }
        }
    };
}

function next_prev_id(el){
    var prev_id = el.prev().attr('id');
    if (prev_id !== undefined)
        prev_id = prev_id.replace('story-', '');
    var next_id = el.next().attr('id');
    if (next_id !== undefined)
        next_id = next_id.replace('story-', '');
    return [prev_id, next_id];
}
