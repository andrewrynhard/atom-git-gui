path = require 'path'
chokidar = require 'chokidar'
{CompositeDisposable} = require 'atom'
{$, View} = require 'space-pen'
GitGuiActionBarView = require './git-gui-action-bar-view'
GitGuiActionView = require './git-gui-action-view'
GitGuiStagingAreaView = require './git-gui-staging-area-view'
GitGuiDiffView = require './git-gui-diff-view'
GitGuiSettingsView = require './git-gui-settings-view'

class GitGuiView extends View
  gitGuiActionBarView: null
  gitGuiStagingAreaView: null
  gitGuiSettingsView: null
  gitGuiActionView: null
  gitGuiDiffView: null
  modalPanel: null

  @content: ->
    @div class: 'git-gui', =>
      @subview 'gitGuiDiffView', new GitGuiDiffView()
      @subview 'gitGuiSettingsView', new GitGuiSettingsView()
      @div class: 'git-gui-overlay', =>
        @subview 'gitGuiActionBarView', new GitGuiActionBarView()
        @div =>
          @select class: 'input-select', id: 'git-gui-project-list'
        @subview 'gitGuiStagingAreaView', new GitGuiStagingAreaView()

  initialize: ->
    @gitGuiActionView = new GitGuiActionView()
    @gitGuiActionView.parentView = this
    @modalPanel = atom.workspace.addModalPanel
      item: @gitGuiActionView,
      visible: false

    @watcher = chokidar.watch(atom.project.getPaths()[0], {ignored: /\.git*/} )
    .on 'change', (path) =>
      @gitGuiStagingAreaView.updateStatus path

    $(document).ready () =>
      $('#git-gui-project-list').on 'change', () =>
        @watcher.close()
        @watcher = chokidar.watch($('#git-gui-project-list').val(), {ignored: /\.git*/} )
        .on 'change', (path) =>
          @gitGuiStagingAreaView.updateStatus path

        @updateAll()
        @selectedProject = $('#git-gui-project-list').val()

    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.project.onDidChangePaths (projectPaths) =>
      @updateProjects(projectPaths)

    @subscriptions.add @gitGuiStagingAreaView.onDidUpdateStatus () =>
      @gitGuiActionBarView.update()

    @subscriptions.add @gitGuiActionView.onDidCommit () =>
      @updateAll()

    @subscriptions.add @gitGuiActionView.onDidPush () =>
      @updateAll()

  serialize: ->

  destroy: ->
    @gitGuiActionBarView.destroy()
    @gitGuiActionView.destroy()
    @gitGuiStagingAreaView.destroy()
    @gitGuiSettingsView.destroy()
    @gitGuiDiffView.destroy()
    @subscriptions.dispose()
    @watcher.close()

  # TODO: keep the currently selected option
  updateProjects: (projectPaths) ->
    $('#git-gui-project-list').find('option').remove().end()
    for projectPath in projectPaths
      option = "<option value=#{projectPath} data-repo='#{path.join projectPath, '.git'}'>#{path.basename projectPath}</option>"
      $('#git-gui-project-list').append option
    if @selectedProject and @selectedProject in atom.project.getPaths()
      $('#git-gui-project-list').val(@selectedProject)
    else
      $('#git-gui-project-list').prop('selectedIndex', 0)
      @selectedProject = $('#git-gui-project-list').val()

  # TODO: This is the only time that the repo and config views are updated,
  #       they need a more dynamic way of updating.
  updateAll: ->
    pathToRepo = path.join $('#git-gui-project-list').val(), '.git'
    @gitGuiStagingAreaView.updateStatuses()
    @gitGuiSettingsView.gitGuiRepoView.updateBranches(pathToRepo)
    @gitGuiSettingsView.gitGuiConfigView.updateConfig(pathToRepo)
    @gitGuiActionView.gitGuiPushView.updateRemotes(pathToRepo)

  open: ->
    if $('.git-gui').hasClass 'open'
      return
    @updateProjects atom.project.getPaths()
    @updateAll()
    $('.git-gui').addClass 'open'

  close: ->
    if ! $('.git-gui').hasClass 'open'
      return
    $('.git-gui').removeClass 'open'

  isOpen: ->
    if $('.git-gui').hasClass 'open'
      return true
    return false

module.exports = GitGuiView
