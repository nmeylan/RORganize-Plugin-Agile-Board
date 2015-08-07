###*
# User: nmeylan
# Date: 02.12.14
# Time: 17:23
###

class @UserStoriesFilters

  @setup: (scope) ->
    if (container = scope.find("[data-role=board-plan]")).length || ((container = scope).is("[data-role=board-plan]"))
      @instance = new UserStoriesFilters(container)

  constructor: (@container) ->
    @initUi()
    @bind_user_story_search_field()

  initUi: ->
    @ui =
      input:  @container.find('#user-stories-search')

  bind_user_story_search_field: ->
    self = @
    anchor = window.location.hash
    el = self.ui.input
    @bind_user_story_search_onclick()
    @bind_clear_input_onclick()
    if el.length > 0
      el.val anchor.replace('#', '')
      self.process_filter(el)
      el.keydown (e) ->
        if e.keyCode == 13
          self.process_filter(el)

  # Bind on click action to apply filter.

  bind_user_story_search_onclick: (_el) ->
    input = @ui.input
    _el = _el or @container.find('.filter-link')
    self = @
    _el.click (e) ->
      el = $(this)
      value = el.text().trim().toLowerCase()
      type = el.data('filtertype')
      criteria = input.val().split(RegExp(' +(?=[\\w]+\\:)', 'g'))
      criterion_type = undefined
      criteria_types = []
      if type == 'tracker'
        value = value.split(/\s/)[0]
      i = 0
      while i < criteria.length
        criterion_type = criteria[i].split(':')[0]
        criteria_types.push criterion_type
        i++
      if criteria_types.indexOf(type) == -1
        s = input.val()
        if s.length > 0
          s += ' '
        input.val s + type + ':' + value
      else
        j = 0
        while j < criteria.length
          criterion_type = criteria[j].split(':')[0]
          if criterion_type == type
            criteria[j] = type + ':' + value
          j++
        input.val criteria.join(' ')
      self.process_filter()

  bind_clear_input_onclick: ->
    input = @ui.input
    self = @
    @container.find('.clear-input-icon').click (e) ->
      input.val ''
      self.process_filter()

  process_filter: ->
    input = @ui.input
    self = @
    stories = @container.find('.fancy-list-item.story')
    text = input.val()
    if text.trim() != ''
      self.bulk_hide(stories)
      selected_stories = self.search_strategy(stories, text)
      self.bulk_show(selected_stories)
    else
      self.bulk_show(stories)
    self.container.find('.box.sprint').each ->
      el = $(this)
      update_sprint_stories_counter el.attr('id')
      update_sprint_story_points_counter el.attr('id')

    self.container.find('.sprint ').find('.fancy-list-item.story:visible').css('border-bottom', '').css 'margin-bottom', ''
    self.container.find('.sprint ').find('.fancy-list-item.story:visible:last').css('border-bottom', 'inherit').css 'margin-bottom', '-6px'
    window.location.hash = text

  bulk_hide: (elements) ->
    @bulk_transform(elements, 'none')

  bulk_show: (elements) ->
    @bulk_transform(elements, 'block')

  bulk_transform: (elements, css) ->
    size = elements.length
    i = 0
    while i < size
      elements[i].style.display = css
      i++

  search_strategy: (stories, text) ->
    criteria_hash = @build_criteria_hash(text)
    self = @
    stories.filter ->
      s = $(this)
      # Should use .reduce() on an array.
      self.is_contained(s, criteria_hash, 'title') and
        self.is_contained(s, criteria_hash, 'epic') and
        self.is_contained(s, criteria_hash, 'category') and
        self.is_contained(s, criteria_hash, 'tracker') and
        self.is_contained(s, criteria_hash, 'status')

  is_contained: (story, criteria_hash, criterion_name) ->
    @is_criterion_empty(story, criteria_hash, criterion_name) or
      @is_criterion_filled(story, criteria_hash, criterion_name) and story.data('search' + criterion_name).toLowerCase().indexOf(criteria_hash[criterion_name].toLowerCase()) > -1

  is_criterion_empty: (story, criteria_hash, criterion_name) ->
    criteria_hash[criterion_name] == undefined and story.data('search' + criterion_name) == undefined or criteria_hash[criterion_name] == undefined

  is_criterion_filled: (story, criteria_hash, criterion_name) ->
    story.data('search' + criterion_name) != undefined and criteria_hash[criterion_name] != undefined

  build_criteria_hash: (text) ->
    criteria = text.split(RegExp(' +(?=[\\w]+\\:)', 'g'))
    size = criteria.length
    hash = {}
    criterion = undefined
    i = 0
    while i < size
      criterion = criteria[i].split(':')
      if criterion.length == 1 and @is_criterion_exist(criterion[0])
        hash['title'] = criterion[0]
      else if @is_criterion_exist(criterion[1])
        hash[criterion[0]] = criterion[1].trim()
      i++
    hash

  is_criterion_exist: (criterion) ->
    criterion != undefined and criterion.trim() != ''
