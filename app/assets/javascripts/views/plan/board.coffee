class @Board

  @setup: (scope) ->
    if (container = scope.find("[data-role=board-plan]")).length || ((container = scope).is("[data-role=board-plan]"))
      @instance = new Board(container)

  constructor: (@container) ->
    @initUi()
    @bindStoryModal()
    @bindSprintModal()

  initUi: ->
    @ui =
      sprints: @container.find("[data-role=sprint]")
      sprintsList: @container.find("[data-role=sprints-list]")

  bindStoryModal: ->
    self = @
    DynamicModal.setup @container,
      selector: "dynamic-modal-story"
      success: (response) ->
        sprint = self.ui.sprints.filter("[data-id=#{response.sprint_id}]")

        if response.action == "create"
          sprint.find("[data-role=stories-list]").append(story = $(response.story))
        else
          sprint.find("#story-#{response.story_id}").replaceWith(story = $(response.story))


        update_sprint_info(response.sprint_id)

        UserStoriesFilters.instance.bind_user_story_search_onclick()
        UserStoriesFilters.instance.process_filter()
        AgileBoardPlugin.setup(story)
        self.bindStoryModal()
        @modal("hide")

  bindSprintModal: ->
    self = @
    DynamicModal.setup @container,
      selector: "dynamic-modal-sprint"
      open: (response) ->
        window.AgileBoardPlugin.setup($(response))
      error: (response) ->
        window.AgileBoardPlugin.setup($(response))
      success: (response) ->
        sprintsList.replaceWith()
        @modal("hide")
