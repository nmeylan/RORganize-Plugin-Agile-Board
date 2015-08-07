
window.AgileBoardPlugin =
  setup: (scope = null, namespace = null) ->
    @scope = $(scope)
    @namespace = namespace if namespace
    @_setup_common()
    if window.AgileBoardPlugin["_setup_#{@namespace}"]
      window.AgileBoardPlugin["_setup_#{@namespace}"]()
    else
      throw "AgileBoardPlugin.setup: setup for namespace '#{namespace}' not found!"

  _setup_front: ->
    Board.setup(@scope)
    UserStoriesFilters.setup(@scope)
    UserStoriesShow.setup(@scope)
    SprintForm.setup(@scope)

  _setup_common: ->