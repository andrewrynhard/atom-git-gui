path = require 'path'
Git = require 'nodegit'
GitGuiView = require './git-gui-view'
{CompositeDisposable} = require 'atom'

module.exports = GitGui =
  gitGuiView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @gitGuiView = new GitGuiView(state.gitGuiViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @gitGuiView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-gui:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @gitGuiView.destroy()

  serialize: ->
    gitGuiViewState: @gitGuiView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      pathToRepo = path.join atom.project.getPaths()[0], '.git'
      Git.Repository.open pathToRepo
      .then (repo) ->
        repo.getBranchCommit 'master'
        .then (commit) ->
          console.log commit
      .catch (error) ->
        console.log error
      @modalPanel.show()
