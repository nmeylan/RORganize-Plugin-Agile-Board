/**
 * User: nmeylan
 * Date: 02.12.14
 * Time: 17:23
 */

function bind_user_story_search_field() {
    var anchor = window.location.hash;
    var self = $("#user-stories-search");
    bind_user_story_search_onclick(self);
    bind_clear_input_onclick(self);
    if (self.length > 0) {
        self.val(anchor.replace('#', ''));
        process_filter(self);
        self.keydown(function (e) {
            if (e.keyCode == 13) {
                process_filter(self);


            }
        });
    }
}
// Bind on click action to apply filter.
function bind_user_story_search_onclick(input, _el) {
    _el = _el || $('.filter-link');
    _el.click(function (e) {
        var el = $(this);
        var value = el.text().trim().toLowerCase();
        var type = el.data('filtertype');
        var criteria = input.val().split(/ +(?=[\w]+\:)/g);
        var criterion_type;
        var criteria_types = [];

        if(type === 'tracker'){
            value = value.split(/\s/)[0];
        }
        for(var i = 0; i < criteria.length; i++){
            criterion_type = criteria[i].split(':')[0];
            criteria_types.push(criterion_type);
        }
        if(criteria_types.indexOf(type) == -1){
            var s = input.val();
            if(s.length > 0){
                s += ' ';
            }
            input.val(s + type + ':' + value);
        }else{
            for(var j = 0; j < criteria.length; j++){
                criterion_type = criteria[j].split(':')[0];
                if(criterion_type === type){
                    criteria[j] = type + ':' + value;
                }
            }
            input.val(criteria.join(' '));
        }
        process_filter(input);
    });
}

function bind_clear_input_onclick(input){
    $('.clear-input-icon').click(function(e){
        input.val('');
        process_filter(input);
    });
}

function process_filter(input) {
    var stories = $(".fancy-list-item.story");
    var text = input.val();
    if (text.trim() !== "") {
        bulk_hide(stories);
        var selected_stories = search_strategy(stories, text);
        bulk_show(selected_stories);
    } else {
        bulk_show(stories);
    }
    $('.box.sprint').each(function () {
        var el = $(this);
        update_sprint_stories_counter(el.attr('id'));
        update_sprint_story_points_counter(el.attr('id'));
    });

    $('.sprint ').find('.fancy-list-item.story:visible').css('border-bottom', '').css('margin-bottom','');
    $('.sprint ').find('.fancy-list-item.story:visible:last').css('border-bottom','inherit').css('margin-bottom','-6px');
    window.location.hash = text;
}

function bulk_hide(elements) {
    bulk_transform(elements, 'none');
}
function bulk_show(elements) {
    bulk_transform(elements, 'block');
}
function bulk_transform(elements, css) {
    var size = elements.length;
    for (var i = 0; i < size; i++) {
        elements[i].style.display = css;
    }
}

function search_strategy(stories, text) {
    var criteria_hash = build_criteria_hash(text);
    return stories.filter(function () {
        var s = $(this);
        // Should use .reduce() on an array.
        return is_contained(s, criteria_hash, 'title') &&
            is_contained(s, criteria_hash, 'epic') &&
            is_contained(s, criteria_hash, 'category') &&
            is_contained(s, criteria_hash, 'tracker') &&
            is_contained(s, criteria_hash, 'status');
    });
}

function is_contained(story, criteria_hash, criterion_name) {
    return is_criterion_empty(story, criteria_hash, criterion_name) ||
        (is_criterion_filled(story, criteria_hash, criterion_name) &&
        story.data("search" + criterion_name).toLowerCase().indexOf(criteria_hash[criterion_name].toLowerCase()) > -1);
}
function is_criterion_empty(story, criteria_hash, criterion_name) {
    return ((criteria_hash[criterion_name] === undefined && story.data("search" + criterion_name) === undefined) || criteria_hash[criterion_name] === undefined);
}
function is_criterion_filled(story, criteria_hash, criterion_name) {
    return (story.data("search" + criterion_name) !== undefined && criteria_hash[criterion_name] !== undefined);
}

function build_criteria_hash(text) {
    var criteria = text.split(/ +(?=[\w]+\:)/g);
    var size = criteria.length;
    var hash = {};
    var criterion;
    for (var i = 0; i < size; i++) {
        criterion = criteria[i].split(':');
        if (criterion.length == 1 && is_criterion_exist(criterion[0])) {
            hash['title'] = criterion[0];
        } else if (is_criterion_exist(criterion[1])) {
            hash[criterion[0]] = criterion[1].trim();
        }
    }
    return hash;
}

function is_criterion_exist(criterion) {
    return criterion !== undefined && criterion.trim() !== "";
}