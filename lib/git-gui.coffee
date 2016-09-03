GitGuiView = require './git-gui-view'
{CompositeDisposable, GitRepository} = require 'atom'
{$} = require 'space-pen'

module.exports = GitGui =
  gitGuiView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @gitGuiView = new GitGuiView(state.gitGuiViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @gitGuiView, visible: true)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-gui:toggle': => @toggle()

    repo = atom.project.getRepositories()[0]

    @subscriptions.add repo.onDidChangeStatus (event) =>
      @gitGuiView.setStatuses()

    @subscriptions.add repo.onDidChangeStatuses () =>
      @gitGuiView.setStatuses()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @gitGuiView.destroy()

  serialize: ->
    gitGuiViewState: @gitGuiView.serialize()

  toggle: ->
    @gitGuiView.setStatuses()
    $(document).ready () =>
      $('#container').toggleClass 'open'
      $('.git-gui-menu-ul li.selected').removeClass 'selected'
      $('.git-gui-subview.active').removeClass 'active'
