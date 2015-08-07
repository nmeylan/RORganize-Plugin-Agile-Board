// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function (e) {
    if (gon.controller === "user_stories" && gon.action === "show") {
        //bind_apply_detach_task_button();
        bind_story_task_sortable();
        //bind_attach_task_button();
    }
});
function bind_story_task_sortable() {
    jQuery(".story-tasks-list.sortable").sortable({
        connectWith: 'ul'
    });
}

function bind_apply_detach_task_button() {
    $("#user-story-detach-tasks").click(function (e) {
        e.preventDefault();
        var el = $(this);
        var list_items = $("#trash-story-tasks > ul > li");
        if (_.any(list_items)) {
            var ids = [];
            var id;
            // Get tasks ids
            list_items.each(function () {
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

function bind_attach_task_button() {

    createOverlay('#story-attach-task-overlay');
    var cacheResponse1 = [];
    $("#story-attach-tasks-textarea").textcomplete([{ // Issues strategy
        match: /(^|\s)#((\w*)|\d*)$/,
        search: function (term, callback) {
            if ($.isEmptyObject(cacheResponse1)) {
                $.getJSON('/projects/' + gon.project_id + '/agile_board/tasks_completion').done(function (response) {
                    cacheResponse1 = response;
                    callback($.map(cacheResponse1, function (issue) {
                        var tmp = '#' + issue[0];
                        var isTermMatch = issue[0].toString().indexOf(term) !== -1 || issue[1].toLowerCase().indexOf(term) !== -1;
                        return isTermMatch ? tmp + ' ' + issue[1] : null;
                    }));
                });
            } else {
                callback($.map(cacheResponse1, function (issue) {
                    var tmp = '#' + issue[0];
                    var isTermMatch = issue[0].toString().indexOf(term) === 0 || issue[1].toLowerCase().indexOf(term) === 0;
                    return isTermMatch ? tmp + ' ' + issue[1] : null;
                }));
            }
        },
        replace: function (value) {
            return '$1' + value.substr(0, value.indexOf(' ')) + ' ';
        },
        cache: false
    }]);
    $("#user-story-attach-tasks").click(function (e) {
        jQuery('#story-attach-task-overlay').overlay().load();

    });
}