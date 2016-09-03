GitGuiView = require './git-gui-view'
{CompositeDisposable} = require 'atom'
{$} = require 'space-pen'

module.exports =
  gitGuiView: null
  modalPanel: null
  subscriptions: null

  # TODO: Update the watched repo when the active atom project changes.
  activate: (state) ->
    @gitGuiView = new GitGuiView(state.gitGuiViewState)
    @modalPanel = atom.workspace.addRightPanel(item: @gitGuiView, visible: true)

    # Events subscribed to in atom's system can be easily cleaned up with a
    # CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'git-gui:toggle': =>
      @toggle()

    repo = atom.project.getRepositories()[0]

    @subscriptions.add repo.onDidChangeStatus () =>
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
    $(document).ready () =>
      $('.git-gui').toggleClass 'open'
      @gitGuiView.setStatuses()
