// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
$(document).ready(function (e) {
    if (gon.controller === "boards") {
        initialize_board();
    }
});

function initialize_board(){
    bind_tab_nav('configuration-tab');
    jQuery(".sortable").sortable({
        update:function( event, ui ){
            var el = $(this);
            var url = el.data('link');
            var ids = el.find('.fancy-list-item');
            var values = [];
            ids.each(function(e){
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
