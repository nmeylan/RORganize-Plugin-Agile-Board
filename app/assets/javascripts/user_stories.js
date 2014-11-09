// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function (e) {
    if (gon.controller === "user_stories" && gon.action === "show") {
        bind_apply_detach_task_button();
        bind_story_task_sortable();
    }
});
function bind_story_task_sortable() {
    jQuery(".story-tasks-list.sortable").sortable({
        connectWith: 'ul'
    });
}

function bind_apply_detach_task_button(){
    $("#user-story-detach-tasks").click(function(e){
        e.preventDefault();
        var el = $(this);
        var list_items = $("#trash-story-tasks > ul > li");
        if(_.any(list_items)){
            var ids = [];
            var id;
            // Get tasks ids
            list_items.each(function(){
                id = $(this).attr('id').split('-');
                ids.push(id[id.length - 1]);
            });
            apprise('Are you sure you want to detach these tasks?', {confirm: true}, function (response) {
                if (response) {
                    jQuery.ajax({
                        url: el.attr('href'),
                        type: 'post',
                        dataType: 'script',
                        data: {ids: ids}
                    });
                }
            });

        }
    });
}