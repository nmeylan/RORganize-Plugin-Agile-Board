/**
 * User: nmeylan
 * Date: 02.12.14
 * Time: 17:23
 */

function bind_user_story_search_field(id) {
    var stories = $(".fancy-list-item.story");
    var anchor = window.location.hash;
    var self = $("#" + id);
    if (self.length > 0) {
        self.val(anchor.replace('#', ''));
        process_filter(self, stories);
        self.keydown(function (e) {
            if (e.keyCode == 13) {
                process_filter(self, stories);

                window.location.hash = self.val();
            }
        });
    }
}

function process_filter(input, stories) {
    var text = input.val();
    if (text.trim() !== "") {
        bulk_hide(stories);
        var selected_stories = search_strategy(stories, text);
        bulk_show(selected_stories);


    } else {
        bulk_show(stories);
    }
    $('.box.sprint').each(function(){
        var el = $(this);
        update_sprint_stories_counter(el.attr('id'));
        update_sprint_story_points_counter(el.attr('id'));
    });
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