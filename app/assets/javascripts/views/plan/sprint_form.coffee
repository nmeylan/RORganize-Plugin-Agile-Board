class @SprintForm

  @setup: (scope) ->
    if (container = scope.find("[data-role=sprint-form]")).length || ((container = scope).is("[data-role=sprint-form]"))
      @instance = new SprintForm(container)

  constructor: (@container) ->
    @initUi()
    @bindEvents()

  initUi: ->
    @ui =
      versionSelect: @container.find("[data-action=generate-sprint-name]")
      sprintName: @container.find("[data-role=sprint-name]")

  bindEvents: ->
    @ui.versionSelect.on "change", @handleVersionChange

  handleVersionChange: (e) =>
    self = @
    el = $(e.target)
    $.get el.data("remote-url"), {value: el.val()}, (response) ->
      self.ui.sprintName.val(response.name)