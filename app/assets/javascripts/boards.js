// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function (e) {
    if (gon.controller === "boards") {
        initialize_board();
    }
});

function initialize_board() {
    bind_tab_nav('configuration-tab');
    bind_stories_sortable();
    multi_toogle('.sprint-expand');
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

function bind_stories_sortable() {
    jQuery(".stories-list.sortable").sortable(sortable_stories_hash());
}

function sortable_stories_hash() {
    return {
        connectWith: 'ul',
        update: function (event, ui) {
            if (this !== ui.item.parent()[0]) {
                var el = ui.item;
                var sprint = $(el.parents(".sprint")[1]);
                console.log(el.parents(".sprint"));
                var id = sprint.attr('id').replace('sprint-', '');
                jQuery.ajax({
                    url: el.data('link'),
                    type: 'post',
                    dataType: 'script',
                    data: {sprint_id: id}
                });
            }
        }
    };
}
