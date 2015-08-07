class @UserStoriesShow
  @setup: (scope) ->
    if (container = scope.find("[data-role=user-stories-show]")).length || ((container = scope).is("[data-role=user-stories-show]"))
      @instance = new UserStoriesShow(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()
    @bindStoryModal()

  initUi: ->
    @ui =
      storyContent: @container.find("[data-role=story-content]")

  bindEvents: ->

  bindStoryModal: ->
    self = @
    DynamicModal.setup @container,
      selector: "dynamic-modal-story"
      success: (response) ->
        self.ui.storyContent.replaceWith(response = $(response.story_content))
        AgileBoardPlugin.setup(response)
        @modal("hide")